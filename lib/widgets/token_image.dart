import 'package:flutter/material.dart';

class TokenImage extends StatelessWidget {
  final bool isNativeToken;
  final String? chain; // Chain name for non-native tokens (e.g., 'solana', 'ethereum')
  final String? tokenImageUrl; // For future backend support
  final String? tokenName; // Token name for native tokens (e.g., 'bitcoin', 'bnb', 'solana')
  final String? tokenAssetName; // Explicit token icon asset (e.g., 'war_token.png')

  const TokenImage({
    super.key,
    required this.isNativeToken,
    this.chain,
    this.tokenImageUrl,
    this.tokenName,
    this.tokenAssetName,
  });

  @override
  Widget build(BuildContext context) {
    if (isNativeToken) {
      // Single native token image 40x40
      if (tokenName != null) {
        // Use chain icon for native token
        return ClipOval(
          child: Image.asset(
            _getChainIconPath(tokenName!),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Failed to load native token icon: ${_getChainIconPath(tokenName!)}');
              return Container(
                width: 40,
                height: 40,
                color: Colors.grey.shade300,
              );
            },
          ),
        );
      }
      // Fallback placeholder
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.circle, size: 40),
      );
    } else {
      // Combined image: token image + chain icon at bottom-right
      return SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main token image (40x40)
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  tokenAssetName != null
                      ? (tokenAssetName!.startsWith('platform_icons/')
                          ? 'assets/$tokenAssetName'
                          : 'assets/token_icons/$tokenAssetName')
                      : 'assets/icons/token_1.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Failed to load token icon: $tokenAssetName');
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey.shade300,
                    );
                  },
                ),
              ),
            ),
            // Chain native token image (20x20) at bottom-right
            if (chain != null)
              Positioned(
                right: -4,
                bottom: -4,
                child: ClipOval(
                  child: Image.asset(
                    _getChainIconPath(chain!),
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if chain icon not found
                      // Debug: print the path that failed
                      debugPrint('Failed to load chain icon: ${_getChainIconPath(chain!)}');
                      return Container(
                        width: 20,
                        height: 20,
                        color: Colors.grey.shade300,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  String _getChainIconPath(String chainName) {
    // Handle common chain name variations
    final chainMap = {
      'solana': 'solana.png',
      'ethereum': 'eth.png',
      'bitcoin': 'bitcoin.png',
      'binance': 'BNB smart.png',
      'bnb': 'BNB smart.png',
      'polygon': 'polygon.png',
      'avalanche': 'avalanche.png',
      'arbitrum': 'arbitrum.png',
      'optimism': 'op mainnet.png',
      'base': 'base.png',
      'eth': 'eth.png',
      'btc': 'bitcoin.png',
    };

    // Check if we have a mapping
    final lowerChain = chainName.toLowerCase();
    if (chainMap.containsKey(lowerChain)) {
      return 'assets/chain_icons/${chainMap[lowerChain]}';
    }

    // Try direct match with original case (for files with spaces like "BNB smart.png")
    return 'assets/chain_icons/$chainName.png';
  }
}
