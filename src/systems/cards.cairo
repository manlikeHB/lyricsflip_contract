use lyricsflip::constants::{Genre};

#[starknet::interface]
pub trait ICardActions<TContractState> {
    fn create_card(ref self: TContractState, card_id: u256);
}

// dojo decorator
#[dojo::contract]
pub mod cards {
    use super::{ICardActions};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use lyricsflip::models::card::{Card};
    use lyricsflip::constants::{GAME_ID, Genre};

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    #[derive(Drop, Copy, Serde)]
    #[dojo::event]
    pub struct RoundCreated {
        #[key]
        pub round_id: u256,
        pub creator: ContractAddress,
    }

    #[abi(embed_v0)]
    impl CardActionsImpl of ICardActions<ContractState> {
        fn create_card(ref self: ContractState, card_id: u256) {
            // Get the default world.
            let mut world = self.world_default();

            // get caller address
            let caller = get_caller_address();

            let new_card = Card {
                card_id,
                genre: 'Pop',
                artist: 'fame',
                title: 't1',
                year: 2020,
                lyrics: 'some lyrics',
            };

            // write new round to world
            world.write_model(@new_card);
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
