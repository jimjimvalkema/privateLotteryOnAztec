use std::hash::poseidon;

fn main(
    x:pub u64,
    domain:pub u64,
    seed:pub Field,
    rounds:pub u64, // could be hardcoded
 ) -> pub u64 {
    shuffle(x,domain,seed,rounds)
}


/**
 * Compute the next perfect square of `n`, unless it's already a perfect square.
 * @param n input
 */
fn next_perfect_square(n: u64)-> u64 {
    let sqrtN: u64 = usqrt(n);
    let mut out: u64 = 0;
    if (sqrtN * sqrtN == n) {
        out = n;
    } else {
        let sqrtN_plus_one = sqrtN + 1;
        out = sqrtN_plus_one * sqrtN_plus_one;
    }
    out
}

fn next_perfect_square_root(n: u64)-> u64 {
    let sqrtN: u64 = usqrt(n);
    let mut out: u64 = 0;
    if (sqrtN * sqrtN == n) {
        out = sqrtN;
    } else {
        out =  sqrtN + 1;
    }
    out
}

fn usqrt(s: u64)-> u64 {
    let mut z = 0;
    if (s > 3) {
        z = s;
        let mut x = s / 2 + 1;
        for index in 0 .. 40 { //0 .. 36 should be enough for u64, 40 to be safe (is the upper bound for u64 36 because: Math.log2(64) ** 2 = 36???)
            if x < z {
                z = x;
                x = (s / x + x) / 2; 
            }
            
        }
    } else if (s != 0) {
        z = 1;
    }
    z
}

fn shuffle(
    _x: u64,
    domain: u64,
    seed: Field,
    rounds: u64
) -> u64 {
    assert(domain != 0, "modulus must be > 0");
    assert(_x < domain, "_x too large");
    assert((rounds & 1) == 0, "rounds must be even");

    let h = next_perfect_square_root(domain);
    
    let mut x = _x;
    let mut needs_permute = true;
    for index in 0 .. 10 { // TODO find the actual upperbound of this loop (is it 3?)
        if (needs_permute ) {
            let mut L = x % h;
            let mut R = x / h;
            for i in  0 .. rounds {
                let hash =  poseidon::bn254::hash_4([R as Field, i as Field, seed, domain as Field]);
                let nextR = (L + hash as u64) % h;
                L = R;
                R = nextR;
            }
            x = h * R + L;
            needs_permute = x >= domain;
        }
    }
    x
}

#[test]
fn test_main() {
    let seed = 0x1234;
    let rounds = 4; //should be >4
    let domain = 10;

    let mut shuffledIndexes: [u64;10] = [0;10];
    for index in 0 .. domain {
        let shuffledIndex = main(index, domain, seed,rounds);
        shuffledIndexes[index] = shuffledIndex;

        assert(shuffledIndex<domain, "shuffledIndex outside of domain");
        println(shuffledIndex);
    }

    let sorted_shuffledIndexes = shuffledIndexes.sort();
    for index in 0 .. domain {
        assert(sorted_shuffledIndexes[index] == index, "fuck");
    }

}
