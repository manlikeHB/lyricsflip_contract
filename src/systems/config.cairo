use lyricsflip::constants::{Genre};
use starknet::ContractAddress;

#[starknet::interface]
pub trait IGameConfig<TContractState> {
    fn set_game_config(ref self: TContractState, admin_address: ContractAddress);
}

// dojo decorator
#[dojo::contract]
pub mod game_config {
    use super::{IGameConfig};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use lyricsflip::models::config::{GameConfig};
    use lyricsflip::constants::{GAME_ID};

    use core::num::traits::zero::Zero;

    use dojo::model::{Model, ModelStorage};
    use dojo::world::WorldStorage;
    use dojo::world::{IWorldDispatcherTrait};
    use dojo::event::EventStorage;

    pub fn check_caller_is_admin(world: WorldStorage) -> bool {
        // ENSURE
        // 1. ADMIN ADDRESS IS SET (IT MUST NEVER BE THE ZERO ADDRESS)
        // 2. CALLER IS ADMIN
        let mut admin_address = world
            .read_member(Model::<GameConfig>::ptr_from_keys(GAME_ID), selector!("admin_address"));
        return starknet::get_caller_address() == admin_address;
    }

    pub fn assert_caller_is_admin(world: WorldStorage) {
        assert!(check_caller_is_admin(world), "caller not admin");
    }

    #[abi(embed_v0)]
    impl GameConfigImpl of IGameConfig<ContractState> {
        fn set_game_config(ref self: ContractState, admin_address: ContractAddress) {
            // Get the default world.
            let mut world = self.world_default();

            // ensure admin address can't be set to zero
            assert!(admin_address.is_non_zero(), "admin address must be non zero");

            // ensure admin address is not already set
            let mut game_config: GameConfig = world.read_model(GAME_ID);
            // TODO: issue
            if game_config.admin_address.is_non_zero() {
                assert_caller_is_admin(world);
            }

            game_config.admin_address = admin_address;
            world.write_model(@game_config);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        /// Use the default namespace "dojo_starter". This function is handy since the ByteArray
        /// can't be const.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"lyricsflip")
        }
    }
}
