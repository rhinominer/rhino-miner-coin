#!/usr/bin/env python3
"""
Genesis block generator for Rhino Miner Coin (yespower PoW).

Requires a Python yespower module. Supported APIs:
  - yespower.hash(data, version=..., N=..., r=..., pers=...)
  - yespower.yespower(data, version, N, r, pers)

If yespower is unavailable, use --manual to emit the merkle root and a
ready-to-fill C++ snippet for pasting externally computed hashes.
"""

import argparse
import hashlib
import struct
import sys
import time


YESPOWER_0_5 = 5
YESPOWER_1_0 = 10


def sha256d(data):
    return hashlib.sha256(hashlib.sha256(data).digest()).digest()


def push_data(data):
    length = len(data)
    if length < 0x4c:
        return bytes([length]) + data
    if length <= 0xff:
        return b"\x4c" + bytes([length]) + data
    if length <= 0xffff:
        return b"\x4d" + struct.pack("<H", length) + data
    return b"\x4e" + struct.pack("<I", length) + data


def ser_varint(n):
    if n < 0xfd:
        return struct.pack("<B", n)
    if n <= 0xffff:
        return b"\xfd" + struct.pack("<H", n)
    if n <= 0xffffffff:
        return b"\xfe" + struct.pack("<I", n)
    return b"\xff" + struct.pack("<Q", n)


def build_coinbase_script_sig(timestamp):
    part1 = push_data(struct.pack("<I", 486604799))
    part2 = push_data(b"\x04")
    part3 = push_data(timestamp.encode("utf-8"))
    return part1 + part2 + part3


def build_coinbase_tx(timestamp, pubkey_hex, reward_sats):
    pubkey = bytes.fromhex(pubkey_hex)
    script_sig = build_coinbase_script_sig(timestamp)
    script_pubkey = push_data(pubkey) + b"\xac"  # OP_CHECKSIG

    tx = b""
    tx += struct.pack("<I", 1)  # nVersion
    tx += ser_varint(1)  # vin count
    tx += b"\x00" * 32  # prevout hash
    tx += struct.pack("<I", 0xffffffff)  # prevout index
    tx += ser_varint(len(script_sig)) + script_sig
    tx += struct.pack("<I", 0xffffffff)  # sequence
    tx += ser_varint(1)  # vout count
    tx += struct.pack("<Q", reward_sats)
    tx += ser_varint(len(script_pubkey)) + script_pubkey
    tx += struct.pack("<I", 0)  # locktime
    return tx


def bits_to_target(bits):
    exponent = bits >> 24
    mantissa = bits & 0x007fffff
    if bits & 0x00800000:
        mantissa *= -1
    target = mantissa * (1 << (8 * (exponent - 3)))
    return target


def load_yespower():
    try:
        import yespower  # type: ignore
    except Exception as exc:
        raise RuntimeError("Missing yespower module: %s" % exc)
    return yespower


def yespower_hash(data, ntime):
    yespower = load_yespower()
    if ntime > 1553904000:
        params = {
            "version": YESPOWER_1_0,
            "N": 4096,
            "r": 16,
            "pers": None,
        }
    else:
        params = {
            "version": YESPOWER_0_5,
            "N": 4096,
            "r": 16,
            "pers": b"Client Key",
        }

    if hasattr(yespower, "hash"):
        return yespower.hash(data, **params)
    if hasattr(yespower, "yespower"):
        return yespower.yespower(data, params["version"], params["N"], params["r"], params["pers"])
    raise RuntimeError("Unsupported yespower module API")


def block_hash(header, ntime):
    if ntime > 1675036800:
        return sha256d(header)
    return yespower_hash(header, ntime)


def pow_hash(header, ntime):
    return yespower_hash(header, ntime)


def to_display_hash(h):
    return h[::-1].hex()


def mine_genesis(timestamp, pubkey, ntime, nbits, version, reward, start_nonce, max_nonce):
    tx = build_coinbase_tx(timestamp, pubkey, reward)
    merkle_root = sha256d(tx)
    merkle_root_le = merkle_root[::-1]
    target = bits_to_target(nbits)

    for nonce in range(start_nonce, max_nonce + 1):
        header = b"".join([
            struct.pack("<I", version),
            b"\x00" * 32,
            merkle_root_le,
            struct.pack("<I", ntime),
            struct.pack("<I", nbits),
            struct.pack("<I", nonce),
        ])
        h_pow = pow_hash(header, ntime)
        if int.from_bytes(h_pow, "little") <= target:
            h_block = block_hash(header, ntime)
            return {
                "nonce": nonce,
                "merkle_root": merkle_root.hex(),
                "block_hash": to_display_hash(h_block),
                "pow_hash": to_display_hash(h_pow),
                "header": header,
            }
    return None


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--timestamp", required=True, help="Genesis timestamp string")
    parser.add_argument("--pubkey", required=True, help="Genesis pubkey hex (uncompressed)")
    parser.add_argument("--time", type=int, default=int(time.time()), help="nTime (default: now)")
    parser.add_argument("--bits", type=lambda x: int(x, 16), required=True, help="nBits in hex, e.g. 0x1e3fffff")
    parser.add_argument("--version", type=int, default=1, help="Block version")
    parser.add_argument("--reward", type=int, default=50 * 100000000, help="Genesis reward in satoshis")
    parser.add_argument("--start-nonce", type=int, default=0)
    parser.add_argument("--max-nonce", type=int, default=0xffffffff)
    parser.add_argument("--manual", action="store_true", help="Print merkle root and a placeholder snippet without mining")
    return parser.parse_args()


def main():
    args = parse_args()
    if args.manual:
        tx = build_coinbase_tx(args.timestamp, args.pubkey, args.reward)
        merkle_root = sha256d(tx)
        print("nTime:        %d" % args.time)
        print("nBits:        0x%08x" % args.bits)
        print("MerkleRoot:   %s" % merkle_root.hex())
        print("")
        print("C++ snippet (fill hashes/nonces from external miner):")
        print("  genesis = CreateGenesisBlock(%d, <NONCE>, 0x%08x, %d, %d * COIN);" % (
            args.time, args.bits, args.version, args.reward // 100000000
        ))
        print("  consensus.hashGenesisBlock = uint256S(\"0x<GENESIS_HASH>\");")
        print("  assert(genesis.hashMerkleRoot == uint256S(\"0x%s\"));" % merkle_root.hex())
        return
    result = mine_genesis(
        timestamp=args.timestamp,
        pubkey=args.pubkey,
        ntime=args.time,
        nbits=args.bits,
        version=args.version,
        reward=args.reward,
        start_nonce=args.start_nonce,
        max_nonce=args.max_nonce,
    )
    if not result:
        print("Genesis not found within nonce range.", file=sys.stderr)
        sys.exit(1)

    print("nTime:        %d" % args.time)
    print("nBits:        0x%08x" % args.bits)
    print("nNonce:       %d" % result["nonce"])
    print("MerkleRoot:   %s" % result["merkle_root"])
    print("BlockHash:    %s" % result["block_hash"])
    print("PoWHash:      %s" % result["pow_hash"])
    print("")
    print("C++ snippet:")
    print("  genesis = CreateGenesisBlock(%d, %d, 0x%08x, %d, %d * COIN);" % (
        args.time, result["nonce"], args.bits, args.version, args.reward // 100000000
    ))
    print("  consensus.hashGenesisBlock = uint256S(\"0x%s\");" % result["block_hash"])
    print("  assert(genesis.hashMerkleRoot == uint256S(\"0x%s\"));" % result["merkle_root"])


if __name__ == "__main__":
    main()
