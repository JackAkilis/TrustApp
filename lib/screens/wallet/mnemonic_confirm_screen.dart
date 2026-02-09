import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';
import '../../services/wallet_storage.dart';
import 'wallet_details_screen.dart';

class MnemonicConfirmScreen extends StatefulWidget {
  final List<String> mnemonicWords;
  final String walletName;

  const MnemonicConfirmScreen({
    super.key,
    required this.mnemonicWords,
    required this.walletName,
  });

  @override
  State<MnemonicConfirmScreen> createState() => _MnemonicConfirmScreenState();
}

class _MnemonicConfirmScreenState extends State<MnemonicConfirmScreen> {
  final Map<int, String> _selectedWords = {};
  final List<int> _wordsToConfirm = [];
  final Map<int, List<String>> _wordOptions = {};
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _generateConfirmationWords();
  }

  void _generateConfirmationWords() {
    final random = Random();
    // Select 4 random word positions to confirm (excluding duplicates)
    final positions = <int>{};
    while (positions.length < 4 && positions.length < widget.mnemonicWords.length) {
      positions.add(random.nextInt(widget.mnemonicWords.length));
    }
    _wordsToConfirm.addAll(positions.toList()..sort());

    // Generate options for each word to confirm
    for (final position in _wordsToConfirm) {
      final correctWord = widget.mnemonicWords[position];
      final options = <String>[correctWord];
      
      // Add 2 random incorrect words
      while (options.length < 3) {
        final randomWord = widget.mnemonicWords[random.nextInt(widget.mnemonicWords.length)];
        if (!options.contains(randomWord)) {
          options.add(randomWord);
        }
      }
      
      // Shuffle options
      options.shuffle(random);
      _wordOptions[position] = options;
    }
  }

  void _selectWord(int position, String word) {
    setState(() {
      _selectedWords[position] = word;
      _checkConfirmation();
    });
  }

  void _checkConfirmation() {
    // Enable confirm button when all words are selected
    final allSelected = _selectedWords.length == _wordsToConfirm.length;
    setState(() {
      _isConfirmed = allSelected;
    });
  }

  Future<void> _confirmMnemonic() async {
    // Check if all selected words are correct
    bool allCorrect = true;
    for (final position in _wordsToConfirm) {
      if (_selectedWords[position] != widget.mnemonicWords[position]) {
        allCorrect = false;
        break;
      }
    }
    
    if (allCorrect) {
      // Mark manual backup as completed
      await WalletStorage.saveManualBackup(true);
      
      if (mounted) {
        // Pop back to wallet details screen and return true to indicate success
        Navigator.pop(context, true); // Pop confirm screen with result
        Navigator.pop(context, true); // Pop display screen with result
      }
    } else {
      // Show error modal if words are incorrect
      if (mounted) {
        _showIncorrectModal(context);
      }
    }
  }

  void _showIncorrectModal(BuildContext context) {
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Incorrect',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          content: Text(
            'Selections not matched. Please try again.',
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Clear selections
                  setState(() {
                    _selectedWords.clear();
                    _isConfirmed = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final grayColor = ThemeHelper.getGrayColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Confirm mnemonic phrase',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions
                    Text(
                      'Please click on the correct mnemonic phrase below.',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Word confirmation sections
                    ..._wordsToConfirm.map((position) {
                      final wordIndex = position + 1;
                      final options = _wordOptions[position] ?? [];
                      final selectedWord = _selectedWords[position];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Word #$wordIndex',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: options.map((word) {
                                final isSelected = selectedWord == word;

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: ElevatedButton(
                                      onPressed: () => _selectWord(position, word),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSelected
                                            ? primaryColor
                                            : grayColor,
                                        foregroundColor: isSelected
                                            ? Colors.white
                                            : textColor,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        minimumSize: const Size(0, 36),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        word,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Confirm button at bottom
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConfirmed ? _confirmMnemonic : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: grayColor,
                    disabledForegroundColor: secondaryTextColor,
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
