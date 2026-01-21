// Genesis miner for Rhino Miner Coin (yespower PoW).

#include <stdint.h>

#include <algorithm>
#include <atomic>
#include <chrono>
#include <iomanip>
#include <iostream>
#include <limits>
#include <mutex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

#include <boost/multiprecision/cpp_int.hpp>

extern "C" {
#include "sha256.h"
#include "yespower.h"
int yespower_hash(const char *input, char *output);
}

using boost::multiprecision::cpp_int;

static std::vector<uint8_t> HexToBytes(const std::string& hex) {
    if (hex.size() % 2 != 0) {
        throw std::runtime_error("hex string must be even length");
    }
    std::vector<uint8_t> out;
    out.reserve(hex.size() / 2);
    for (size_t i = 0; i < hex.size(); i += 2) {
        unsigned int byte = 0;
        std::stringstream ss;
        ss << std::hex << hex.substr(i, 2);
        ss >> byte;
        out.push_back(static_cast<uint8_t>(byte));
    }
    return out;
}

static std::string BytesToHex(const uint8_t* data, size_t len, bool reverse) {
    std::ostringstream ss;
    ss << std::hex << std::setfill('0');
    if (reverse) {
        for (size_t i = 0; i < len; ++i) {
            ss << std::setw(2) << static_cast<int>(data[len - 1 - i]);
        }
    } else {
        for (size_t i = 0; i < len; ++i) {
            ss << std::setw(2) << static_cast<int>(data[i]);
        }
    }
    return ss.str();
}

static std::vector<uint8_t> PushData(const std::vector<uint8_t>& data) {
    std::vector<uint8_t> out;
    const size_t len = data.size();
    if (len < 0x4c) {
        out.push_back(static_cast<uint8_t>(len));
    } else if (len <= 0xff) {
        out.push_back(0x4c);
        out.push_back(static_cast<uint8_t>(len));
    } else if (len <= 0xffff) {
        out.push_back(0x4d);
        out.push_back(static_cast<uint8_t>(len & 0xff));
        out.push_back(static_cast<uint8_t>((len >> 8) & 0xff));
    } else {
        out.push_back(0x4e);
        out.push_back(static_cast<uint8_t>(len & 0xff));
        out.push_back(static_cast<uint8_t>((len >> 8) & 0xff));
        out.push_back(static_cast<uint8_t>((len >> 16) & 0xff));
        out.push_back(static_cast<uint8_t>((len >> 24) & 0xff));
    }
    out.insert(out.end(), data.begin(), data.end());
    return out;
}

static std::vector<uint8_t> VarInt(uint64_t v) {
    std::vector<uint8_t> out;
    if (v < 0xfd) {
        out.push_back(static_cast<uint8_t>(v));
    } else if (v <= 0xffff) {
        out.push_back(0xfd);
        out.push_back(static_cast<uint8_t>(v & 0xff));
        out.push_back(static_cast<uint8_t>((v >> 8) & 0xff));
    } else if (v <= 0xffffffffULL) {
        out.push_back(0xfe);
        for (int i = 0; i < 4; ++i) out.push_back(static_cast<uint8_t>((v >> (8 * i)) & 0xff));
    } else {
        out.push_back(0xff);
        for (int i = 0; i < 8; ++i) out.push_back(static_cast<uint8_t>((v >> (8 * i)) & 0xff));
    }
    return out;
}

static std::vector<uint8_t> BuildCoinbaseScriptSig(const std::string& timestamp) {
    std::vector<uint8_t> script;
    std::vector<uint8_t> nbits = {0xff, 0xff, 0x00, 0x1d}; // 486604799 LE
    std::vector<uint8_t> four = {0x04};
    std::vector<uint8_t> ts(timestamp.begin(), timestamp.end());
    auto p1 = PushData(nbits);
    auto p2 = PushData(four);
    auto p3 = PushData(ts);
    script.insert(script.end(), p1.begin(), p1.end());
    script.insert(script.end(), p2.begin(), p2.end());
    script.insert(script.end(), p3.begin(), p3.end());
    return script;
}

static std::vector<uint8_t> BuildCoinbaseTx(const std::string& timestamp, const std::string& pubkey_hex, uint64_t reward) {
    std::vector<uint8_t> tx;
    auto script_sig = BuildCoinbaseScriptSig(timestamp);
    auto pubkey = HexToBytes(pubkey_hex);
    auto pubkey_push = PushData(pubkey);
    std::vector<uint8_t> script_pubkey;
    script_pubkey.insert(script_pubkey.end(), pubkey_push.begin(), pubkey_push.end());
    script_pubkey.push_back(0xac); // OP_CHECKSIG

    auto vin_count = VarInt(1);
    auto vout_count = VarInt(1);
    auto script_sig_len = VarInt(script_sig.size());
    auto script_pubkey_len = VarInt(script_pubkey.size());

    // version
    tx.insert(tx.end(), {0x01, 0x00, 0x00, 0x00});
    // vin count
    tx.insert(tx.end(), vin_count.begin(), vin_count.end());
    // prevout hash (32 bytes)
    tx.insert(tx.end(), 32, 0x00);
    // prevout index
    tx.insert(tx.end(), {0xff, 0xff, 0xff, 0xff});
    // scriptSig length + scriptSig
    tx.insert(tx.end(), script_sig_len.begin(), script_sig_len.end());
    tx.insert(tx.end(), script_sig.begin(), script_sig.end());
    // sequence
    tx.insert(tx.end(), {0xff, 0xff, 0xff, 0xff});
    // vout count
    tx.insert(tx.end(), vout_count.begin(), vout_count.end());
    // value (8 bytes little endian)
    for (int i = 0; i < 8; ++i) tx.push_back(static_cast<uint8_t>((reward >> (8 * i)) & 0xff));
    // scriptPubKey length + scriptPubKey
    tx.insert(tx.end(), script_pubkey_len.begin(), script_pubkey_len.end());
    tx.insert(tx.end(), script_pubkey.begin(), script_pubkey.end());
    // locktime
    tx.insert(tx.end(), {0x00, 0x00, 0x00, 0x00});
    return tx;
}

static void Sha256D(const uint8_t* data, size_t len, uint8_t out[32]) {
    uint8_t tmp[32];
    SHA256_Buf(data, len, tmp);
    SHA256_Buf(tmp, sizeof(tmp), out);
}

static cpp_int TargetFromBits(uint32_t bits) {
    uint32_t exponent = bits >> 24;
    uint32_t mantissa = bits & 0x007fffff;
    cpp_int target = mantissa;
    if (exponent <= 3) {
        target >>= 8 * (3 - exponent);
    } else {
        target <<= 8 * (exponent - 3);
    }
    return target;
}

static cpp_int HashToIntLE(const uint8_t* hash) {
    cpp_int value = 0;
    for (int i = 31; i >= 0; --i) {
        value <<= 8;
        value += hash[i];
    }
    return value;
}

static void Usage() {
    std::cerr << "Usage: genesis_miner --timestamp <str> --pubkey <hex> --time <unix> --bits <hex> [--version 1] [--reward sats] [--threads N]\n";
}

int main(int argc, char** argv) {
    std::string timestamp;
    std::string pubkey_hex;
    uint32_t ntime = 0;
    uint32_t nbits = 0;
    uint32_t version = 1;
    uint64_t reward = 50ULL * 100000000ULL;
    uint32_t start_nonce = 0;
    uint32_t max_nonce = std::numeric_limits<uint32_t>::max();
    unsigned int threads = 0;

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        auto next = [&](std::string& out) {
            if (i + 1 >= argc) throw std::runtime_error("Missing value for " + arg);
            out = argv[++i];
        };
        if (arg == "--timestamp") next(timestamp);
        else if (arg == "--pubkey") next(pubkey_hex);
        else if (arg == "--time") { std::string v; next(v); ntime = static_cast<uint32_t>(std::stoul(v)); }
        else if (arg == "--bits") {
            std::string v; next(v);
            nbits = static_cast<uint32_t>(std::stoul(v, nullptr, 16));
        }
        else if (arg == "--version") { std::string v; next(v); version = static_cast<uint32_t>(std::stoul(v)); }
        else if (arg == "--reward") { std::string v; next(v); reward = std::stoull(v); }
        else if (arg == "--start-nonce") { std::string v; next(v); start_nonce = static_cast<uint32_t>(std::stoul(v)); }
        else if (arg == "--max-nonce") { std::string v; next(v); max_nonce = static_cast<uint32_t>(std::stoul(v)); }
        else if (arg == "--threads") { std::string v; next(v); threads = static_cast<unsigned int>(std::stoul(v)); }
        else {
            Usage();
            return 1;
        }
    }

    if (timestamp.empty() || pubkey_hex.empty() || ntime == 0 || nbits == 0) {
        Usage();
        return 1;
    }

    auto tx = BuildCoinbaseTx(timestamp, pubkey_hex, reward);
    uint8_t merkle_root[32];
    Sha256D(tx.data(), tx.size(), merkle_root);

    cpp_int target = TargetFromBits(nbits);

    if (threads == 0) {
        threads = std::max(1u, std::thread::hardware_concurrency());
    }

    const uint32_t log_interval = 10000;
    auto start_time = std::chrono::steady_clock::now();
    std::cerr << "Mining genesis...\n";
    std::cerr << "  nTime:  " << ntime << "\n";
    std::cerr << "  nBits:  0x" << std::hex << std::setw(8) << std::setfill('0') << nbits << std::dec << "\n";
    std::cerr << "  start:  " << start_nonce << "\n";
    std::cerr << "  end:    " << max_nonce << "\n";
    std::cerr << "  threads:" << " " << threads << "\n";
    std::cerr << "  merkle: " << BytesToHex(merkle_root, 32, true) << "\n";

    std::atomic<bool> found{false};
    std::atomic<uint32_t> found_nonce{0};
    std::atomic<uint64_t> total_checked{0};
    std::atomic<uint32_t> last_nonce{start_nonce};
    std::mutex result_mutex;
    uint8_t found_pow_hash[32]{0};

    auto worker = [&](unsigned int thread_index) {
        uint32_t nonce = start_nonce + thread_index;
        while (!found.load(std::memory_order_relaxed) && nonce <= max_nonce) {
            std::vector<uint8_t> header;
            header.reserve(80);
            // version
            header.push_back(static_cast<uint8_t>(version & 0xff));
            header.push_back(static_cast<uint8_t>((version >> 8) & 0xff));
            header.push_back(static_cast<uint8_t>((version >> 16) & 0xff));
            header.push_back(static_cast<uint8_t>((version >> 24) & 0xff));
            // prev block hash (32 bytes)
            header.insert(header.end(), 32, 0x00);
        // merkle root (internal byte order)
        header.insert(header.end(), merkle_root, merkle_root + 32);
            // time
            header.push_back(static_cast<uint8_t>(ntime & 0xff));
            header.push_back(static_cast<uint8_t>((ntime >> 8) & 0xff));
            header.push_back(static_cast<uint8_t>((ntime >> 16) & 0xff));
            header.push_back(static_cast<uint8_t>((ntime >> 24) & 0xff));
            // bits
            header.push_back(static_cast<uint8_t>(nbits & 0xff));
            header.push_back(static_cast<uint8_t>((nbits >> 8) & 0xff));
            header.push_back(static_cast<uint8_t>((nbits >> 16) & 0xff));
            header.push_back(static_cast<uint8_t>((nbits >> 24) & 0xff));
            // nonce
            header.push_back(static_cast<uint8_t>(nonce & 0xff));
            header.push_back(static_cast<uint8_t>((nonce >> 8) & 0xff));
            header.push_back(static_cast<uint8_t>((nonce >> 16) & 0xff));
            header.push_back(static_cast<uint8_t>((nonce >> 24) & 0xff));

            uint8_t pow_hash[32];
            if (yespower_hash(reinterpret_cast<const char*>(header.data()), reinterpret_cast<char*>(pow_hash)) != 0) {
                throw std::runtime_error("yespower_hash failed");
            }
            if (HashToIntLE(pow_hash) <= target) {
                if (!found.exchange(true)) {
                    std::lock_guard<std::mutex> lock(result_mutex);
                    found_nonce.store(nonce);
                    std::copy(pow_hash, pow_hash + 32, found_pow_hash);
                }
                break;
            }

            total_checked.fetch_add(1, std::memory_order_relaxed);
            if ((nonce % log_interval) == 0) {
                last_nonce.store(nonce, std::memory_order_relaxed);
            } else if ((nonce & 0x3fff) == 0) {
                last_nonce.store(nonce, std::memory_order_relaxed);
            }

            if (max_nonce - nonce < threads) {
                break;
            }
            nonce += threads;
        }
        last_nonce.store(nonce, std::memory_order_relaxed);
    };

    std::vector<std::thread> workers;
    workers.reserve(threads);
    for (unsigned int i = 0; i < threads; ++i) {
        workers.emplace_back(worker, i);
    }

    auto log_thread = std::thread([&]() {
        while (!found.load(std::memory_order_relaxed)) {
            std::this_thread::sleep_for(std::chrono::seconds(10));
            uint64_t checked = total_checked.load(std::memory_order_relaxed);
            auto now = std::chrono::steady_clock::now();
            auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - start_time).count();
            if (elapsed == 0) elapsed = 1;
            double rate = static_cast<double>(checked) / static_cast<double>(elapsed);
            std::cerr << "Progress: checked " << checked << " nonces, rate "
                      << static_cast<uint64_t>(rate) << " H/s, last nonce "
                      << last_nonce.load(std::memory_order_relaxed) << "\n";
        }
    });

    for (auto& t : workers) t.join();
    found.store(true);
    log_thread.join();

    if (found.load()) {
        uint32_t nonce = found_nonce.load();
        std::vector<uint8_t> header;
        header.reserve(80);
        header.push_back(static_cast<uint8_t>(version & 0xff));
        header.push_back(static_cast<uint8_t>((version >> 8) & 0xff));
        header.push_back(static_cast<uint8_t>((version >> 16) & 0xff));
        header.push_back(static_cast<uint8_t>((version >> 24) & 0xff));
        header.insert(header.end(), 32, 0x00);
        header.insert(header.end(), merkle_root, merkle_root + 32);
        header.push_back(static_cast<uint8_t>(ntime & 0xff));
        header.push_back(static_cast<uint8_t>((ntime >> 8) & 0xff));
        header.push_back(static_cast<uint8_t>((ntime >> 16) & 0xff));
        header.push_back(static_cast<uint8_t>((ntime >> 24) & 0xff));
        header.push_back(static_cast<uint8_t>(nbits & 0xff));
        header.push_back(static_cast<uint8_t>((nbits >> 8) & 0xff));
        header.push_back(static_cast<uint8_t>((nbits >> 16) & 0xff));
        header.push_back(static_cast<uint8_t>((nbits >> 24) & 0xff));
        header.push_back(static_cast<uint8_t>(nonce & 0xff));
        header.push_back(static_cast<uint8_t>((nonce >> 8) & 0xff));
        header.push_back(static_cast<uint8_t>((nonce >> 16) & 0xff));
        header.push_back(static_cast<uint8_t>((nonce >> 24) & 0xff));

        uint8_t block_hash[32];
        if (ntime > 1675036800) {
            Sha256D(header.data(), header.size(), block_hash);
        } else {
            std::copy(found_pow_hash, found_pow_hash + 32, block_hash);
        }

        std::cout << "nTime:        " << ntime << "\n";
        std::cout << "nBits:        0x" << std::hex << std::setw(8) << std::setfill('0') << nbits << std::dec << "\n";
        std::cout << "nNonce:       " << nonce << "\n";
        std::cout << "MerkleRoot:   " << BytesToHex(merkle_root, 32, true) << "\n";
        std::cout << "BlockHash:    " << BytesToHex(block_hash, 32, true) << "\n";
        std::cout << "PoWHash:      " << BytesToHex(found_pow_hash, 32, true) << "\n\n";

        std::cout << "C++ snippet:\n";
        std::cout << "  genesis = CreateGenesisBlock(" << ntime << ", " << nonce
                  << ", 0x" << std::hex << std::setw(8) << std::setfill('0') << nbits
                  << std::dec << ", " << version << ", " << (reward / 100000000ULL) << " * COIN);\n";
        std::cout << "  consensus.hashGenesisBlock = uint256S(\"0x" << BytesToHex(block_hash, 32, true) << "\");\n";
        std::cout << "  assert(genesis.hashMerkleRoot == uint256S(\"0x" << BytesToHex(merkle_root, 32, true) << "\"));\n";
        return 0;
    }

    std::cerr << "Genesis not found within nonce range.\n";
    return 1;
}
