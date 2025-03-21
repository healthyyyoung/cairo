use crate::blake::{blake2s_compress, blake2s_finalize};
use crate::hash::{HashStateExTrait, HashStateTrait};
use crate::poseidon::PoseidonTrait;
use crate::test::test_utils::assert_eq;

#[test]
fn test_pedersen_hash() {
    assert_eq(
        @crate::pedersen::pedersen(1, 2),
        @2592987851775965742543459319508348457290966253241455514226127639100457844774,
        'Wrong hash value',
    );
}

#[test]
fn test_poseidon_hades_permutation() {
    let (s0, s1, s2) = crate::poseidon::hades_permutation(1, 2, 3);
    assert_eq(
        @s0,
        @442682200349489646213731521593476982257703159825582578145778919623645026501,
        'wrong s0',
    );
    assert_eq(
        @s1,
        @2233832504250924383748553933071188903279928981104663696710686541536735838182,
        'wrong s1',
    );
    assert_eq(
        @s2,
        @2512222140811166287287541003826449032093371832913959128171347018667852712082,
        'wrong s2',
    );
}

#[test]
fn test_poseidon_hash_span() {
    // Test odd number of inputs.
    assert_eq!(
        crate::poseidon::poseidon_hash_span([1, 2, 3].span()),
        0x2f0d8840bcf3bc629598d8a6cc80cb7c0d9e52d93dab244bbf9cd0dca0ad082,
    );

    // Test even number of inputs.
    assert_eq!(
        crate::poseidon::poseidon_hash_span([1, 2, 3, 4].span()),
        0x26e3ad8b876e02bc8a4fc43dad40a8f81a6384083cabffa190bcf40d512ae1d,
    );
}

#[derive(Hash)]
enum EnumForHash {
    First,
    Second: felt252,
    Third: (felt252, felt252),
}

#[derive(Hash)]
struct StructForHash {
    first: (),
    second: felt252,
    third: (felt252, felt252),
}

#[test]
fn test_user_defined_hash() {
    assert_eq(
        @PoseidonTrait::new().update_with(EnumForHash::First).finalize(),
        @PoseidonTrait::new().update(0).finalize(),
        'Bad hash of EnumForHash::First',
    );
    assert_eq(
        @PoseidonTrait::new().update_with(EnumForHash::Second(5)).finalize(),
        @PoseidonTrait::new().update(1).update(5).finalize(),
        'Bad hash of EnumForHash::Second',
    );
    assert_eq(
        @PoseidonTrait::new().update_with(EnumForHash::Third((6, 8))).finalize(),
        @PoseidonTrait::new().update(2).update(6).update(8).finalize(),
        'Bad hash of EnumForHash::Third',
    );
    assert_eq(
        @PoseidonTrait::new()
            .update_with(StructForHash { first: (), second: 10, third: (6, 17) })
            .finalize(),
        @PoseidonTrait::new().update(10).update(6).update(17).finalize(),
        'Bad hash of StructForHash',
    );
}


#[test]
fn test_blake2s() {
    let state = BoxTrait::new([0_u32; 8]);
    let msg = BoxTrait::new([0_u32; 16]);
    let byte_count = 64_u32;

    let res = blake2s_compress(state, byte_count, msg).unbox();

    assert_eq!(
        res,
        [
            3893814314, 2107143640, 4255525973, 2730947657, 3397056017, 3710875177, 3168346915,
            365144891,
        ],
    );

    let res = blake2s_finalize(state, byte_count, msg).unbox();
    assert_eq!(
        res,
        [
            128291589, 1454945417, 3191583614, 1491889056, 794023379, 651000200, 3725903680,
            1044330286,
        ],
    );
}
