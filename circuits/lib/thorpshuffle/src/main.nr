use dep::std::hash::poseidon;
global ROUNDS = 12; //TODO check this. its just comment from kevin

fn f(seed: Field,modulus: u64,x: u64,i: u64) -> u64 {//@TODO  kevins code says x but x % mid goes there at shuffle
    let hash = poseidon::bn254::hash_4([seed, modulus as Field, x as Field, i as Field]);
    hash as u64
}
/// @notice Compute a shuffle mapping for index `x`
/// @param x index of element in the list
/// @param domain Number of elements in the list
/// @param seed Random seed; determines the permutation
/// @param rounds Number of rounds to perform
/// @return resulting shuffled index
fn shuffle(
    mut x: u64,
    domain: u64,
    seed: Field,
    rounds: u64
) -> u64 {
    assert(domain != 0, "modulus must be > 0");
    assert(x < domain, "x too large");

    let mut modulus: u64 = domain;
    if (domain % 2 != 0) {
        modulus = domain + 1;
    }

    let mid: u64  = modulus / 2;
    let mut needs_permute: bool = true; 
    for index in 0 .. 2 {
        if(needs_permute) {
            for  i in 0 .. rounds {
                let c:u64 = f(seed, modulus, x % mid, i) & 1;
                if (x < mid) {
                    x = 2 * x + c;
                } else {
                    x = 2 * (x % mid) + 1 - c;
                }
            }
        }
        needs_permute = x >= domain;   
    }
    x
}


fn main(
    x:pub u64,
    domain:pub u64,
    seed:pub Field,
    //rounds:pub u64, // could be hardcoded
 ) -> pub u64 {
    shuffle(x,domain,seed,ROUNDS)
}


#[test]
fn test_main() {
    let seed = 0x1234;
    let domain = 7;

    let mut shuffledIndexes: [u64;7] = [0;7];
    for index in 0 .. domain {
        let shuffledIndex = main(index, domain, seed);
        shuffledIndexes[index] = shuffledIndex;

        assert(shuffledIndex<domain, "shuffledIndex outside of domain");
        println(shuffledIndex);
    }

    let sorted_shuffledIndexes = shuffledIndexes.sort();
    for index in 0 .. domain {
        assert(sorted_shuffledIndexes[index] == index, "fuck");
    }

}

