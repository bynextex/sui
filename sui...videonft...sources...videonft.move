module examples::videonft {
    use sui::url::{Self, Url};
    use std::string;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::filesystem;
    use sui::random;

    /// NFT'yi temsil eden struct
    struct videonft has key, store {
        id: UID,
        /// Video adi
        name: string::String,
        /// Video URL
        url: Url,
        /// NFT turu (common veya rare)
        nft_type: string::String,
    }

    // ===== Events =====

    struct NFTMinted has copy, drop {
        // NFT'nin Object ID'si
        object_id: ID,
        // NFT'yi olusturan kullanicinin adresi
        creator: address,
        // NFT'nin adi
        name: string::String,
        // NFT'nin turu
        nft_type: string::String,
    }

    // ===== Public view functions =====

    /// NFT'nin `name` ozelligini al
    public fun name(nft: &videonft): &string::String {
        &nft.name
    }

    /// NFT'nin `url` ozelligini al
    public fun url(nft: &videonft): &Url {
        &nft.url
    }

    /// NFT'nin turunu al
    public fun nft_type(nft: &videonft): &string::String {
        &nft.nft_type
    }

    // ===== Entrypoints =====

    /// Yeni bir video NFT'si olustur
    public entry fun mint_video_nft(
        video_name: vector<u8>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        // "common" videolarin bulundugu klasor
        let common_videos_folder = b"/path/to/common/videos";
        // "rare" videolarin bulundugu klasor
        let rare_videos_folder = b"/path/to/rare/videos";

        // Klasordeki videolarin listelerini al
        let common_videos = filesystem::list_files(common_videos_folder);
        let rare_videos = filesystem::list_files(rare_videos_folder);

        // NFT turunu belirle (common veya rare)
        let nft_type = if random::bool() { "common" } else { "rare" };

        // Rastgele bir video sec
        let selected_video = match nft_type {
            "common" => common_videos[random::int(0, common_videos.len() - 1)],
            "rare" => rare_videos[random::int(0, rare_videos.len() - 1)],
            _ => hata!("Gecersiz NFT turu"),
        };

        let nft = videonft {
            id: object::new(ctx),
            name: string::utf8(video_name),
            url: url::new_unsafe_from_bytes(selected_video),
            nft_type: string::utf8(nft_type),
        };

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: sender,
            name: nft.name,
            nft_type: nft.nft_type,
        });

        transfer::public_transfer(nft, sender);
    }
}
