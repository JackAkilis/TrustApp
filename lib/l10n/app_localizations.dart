import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('vi'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Trust App'**
  String get appTitle;

  /// No description provided for @createNewWallet.
  ///
  /// In en, this message translates to:
  /// **'Create new wallet'**
  String get createNewWallet;

  /// No description provided for @iAlreadyHaveWallet.
  ///
  /// In en, this message translates to:
  /// **'I already have a wallet'**
  String get iAlreadyHaveWallet;

  /// No description provided for @unlockOpportunities100Chains.
  ///
  /// In en, this message translates to:
  /// **'Unlock opportunities across 100+ chains'**
  String get unlockOpportunities100Chains;

  /// No description provided for @earnRewardsBuyCryptoSwapTokens.
  ///
  /// In en, this message translates to:
  /// **'Earn rewards, buy crypto, swap tokens'**
  String get earnRewardsBuyCryptoSwapTokens;

  /// No description provided for @exploreLimitlessDapps.
  ///
  /// In en, this message translates to:
  /// **'Explore a limitless world of dApps'**
  String get exploreLimitlessDapps;

  /// No description provided for @yourOnestopWeb3Wallet.
  ///
  /// In en, this message translates to:
  /// **'Your one-stop Web3 wallet'**
  String get yourOnestopWeb3Wallet;

  /// No description provided for @ownControlLeverageAssets.
  ///
  /// In en, this message translates to:
  /// **'Own, control, and leverage the power of your digital assets'**
  String get ownControlLeverageAssets;

  /// No description provided for @byTappingAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'By tapping any button you agree and consent to our\n'**
  String get byTappingAgreeTerms;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy.'**
  String get privacyPolicy;

  /// No description provided for @enterPasscode.
  ///
  /// In en, this message translates to:
  /// **'Enter passcode'**
  String get enterPasscode;

  /// No description provided for @confirmPasscode.
  ///
  /// In en, this message translates to:
  /// **'Confirm passcode'**
  String get confirmPasscode;

  /// No description provided for @confirmPasscodeHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your passcode. Be sure to remember it so you can unlock your wallet.'**
  String get confirmPasscodeHint;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// No description provided for @walletCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Wallet Creation Failed'**
  String get walletCreationFailed;

  /// No description provided for @returnToHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get returnToHome;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownErrorOccurred;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @brilliantWalletReady.
  ///
  /// In en, this message translates to:
  /// **'Brilliant, your wallet is ready!'**
  String get brilliantWalletReady;

  /// No description provided for @addFundsToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add funds to get started'**
  String get addFundsToGetStarted;

  /// No description provided for @fundYourWallet.
  ///
  /// In en, this message translates to:
  /// **'Fund your wallet'**
  String get fundYourWallet;

  /// No description provided for @mainWallet.
  ///
  /// In en, this message translates to:
  /// **'Main Wallet'**
  String get mainWallet;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @fund.
  ///
  /// In en, this message translates to:
  /// **'Fund'**
  String get fund;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @earn.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get earn;

  /// No description provided for @myEarnPortfolio.
  ///
  /// In en, this message translates to:
  /// **'My Earn portfolio'**
  String get myEarnPortfolio;

  /// No description provided for @totalStakedRewards.
  ///
  /// In en, this message translates to:
  /// **'Total staked + rewards'**
  String get totalStakedRewards;

  /// No description provided for @yourEarningAssetsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your earning assets will appear here.'**
  String get yourEarningAssetsWillAppearHere;

  /// No description provided for @stablecoinEarn.
  ///
  /// In en, this message translates to:
  /// **'Stablecoin Earn'**
  String get stablecoinEarn;

  /// No description provided for @nativeStaking.
  ///
  /// In en, this message translates to:
  /// **'Native Staking'**
  String get nativeStaking;

  /// No description provided for @upToPercent.
  ///
  /// In en, this message translates to:
  /// **'up to {percent}%'**
  String upToPercent(String percent);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @trade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get trade;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @searchOrEnterDappUrl.
  ///
  /// In en, this message translates to:
  /// **'Search or enter dApp URL'**
  String get searchOrEnterDappUrl;

  /// No description provided for @exploreDapps.
  ///
  /// In en, this message translates to:
  /// **'Explore dApps'**
  String get exploreDapps;

  /// No description provided for @swapHistory.
  ///
  /// In en, this message translates to:
  /// **'Swap history'**
  String get swapHistory;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @backUpToSecureAssets.
  ///
  /// In en, this message translates to:
  /// **'Back up to secure your assets'**
  String get backUpToSecureAssets;

  /// No description provided for @backUpWallet.
  ///
  /// In en, this message translates to:
  /// **'Back up wallet →'**
  String get backUpWallet;

  /// No description provided for @crypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get crypto;

  /// No description provided for @prediction.
  ///
  /// In en, this message translates to:
  /// **'Prediction'**
  String get prediction;

  /// No description provided for @predictionsNew.
  ///
  /// In en, this message translates to:
  /// **'Predictions New'**
  String get predictionsNew;

  /// No description provided for @memeRush.
  ///
  /// In en, this message translates to:
  /// **'Meme Rush'**
  String get memeRush;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @watchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// No description provided for @nfts.
  ///
  /// In en, this message translates to:
  /// **'NFTs'**
  String get nfts;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @manageCrypto.
  ///
  /// In en, this message translates to:
  /// **'Manage crypto'**
  String get manageCrypto;

  /// No description provided for @browsePredictions.
  ///
  /// In en, this message translates to:
  /// **'Browse Predictions'**
  String get browsePredictions;

  /// No description provided for @watchlistWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Watchlist! Save your favorite crypto to keep up with price movements.'**
  String get watchlistWelcome;

  /// No description provided for @createList.
  ///
  /// In en, this message translates to:
  /// **'Create list'**
  String get createList;

  /// No description provided for @noNftsYet.
  ///
  /// In en, this message translates to:
  /// **'No NFTs yet. Purchased or received NFTs will show up here.'**
  String get noNftsYet;

  /// No description provided for @receiveNfts.
  ///
  /// In en, this message translates to:
  /// **'Receive NFTs'**
  String get receiveNfts;

  /// No description provided for @noActiveApprovals.
  ///
  /// In en, this message translates to:
  /// **'You have no active approvals'**
  String get noActiveApprovals;

  /// No description provided for @topMovers.
  ///
  /// In en, this message translates to:
  /// **'Top movers'**
  String get topMovers;

  /// No description provided for @memes.
  ///
  /// In en, this message translates to:
  /// **'Memes'**
  String get memes;

  /// No description provided for @rwas.
  ///
  /// In en, this message translates to:
  /// **'RWAs'**
  String get rwas;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get top;

  /// No description provided for @bnb.
  ///
  /// In en, this message translates to:
  /// **'BNB'**
  String get bnb;

  /// No description provided for @eth.
  ///
  /// In en, this message translates to:
  /// **'ETH'**
  String get eth;

  /// No description provided for @topMemeCoinsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top Meme coins and tokens (24h % price gain)'**
  String get topMemeCoinsSubtitle;

  /// No description provided for @realWorldAssetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-world assets (tokenized securities)'**
  String get realWorldAssetsSubtitle;

  /// No description provided for @aiPoweredTokensSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered tokens (24h % price gain)'**
  String get aiPoweredTokensSubtitle;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all >'**
  String get viewAll;

  /// No description provided for @popularTokens.
  ///
  /// In en, this message translates to:
  /// **'Popular tokens'**
  String get popularTokens;

  /// No description provided for @topTokensByMarketCap.
  ///
  /// In en, this message translates to:
  /// **'Top tokens by total market cap'**
  String get topTokensByMarketCap;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @perps.
  ///
  /// In en, this message translates to:
  /// **'Perps'**
  String get perps;

  /// No description provided for @tradeMarketMoves100Pairs.
  ///
  /// In en, this message translates to:
  /// **'Trade market moves with over 100 pairs'**
  String get tradeMarketMoves100Pairs;

  /// No description provided for @howPerpsWork.
  ///
  /// In en, this message translates to:
  /// **'How perps work?'**
  String get howPerpsWork;

  /// No description provided for @learnPerpsLongShort.
  ///
  /// In en, this message translates to:
  /// **'Learn how to go long or short in minutes.'**
  String get learnPerpsLongShort;

  /// No description provided for @upTo100xLeverage.
  ///
  /// In en, this message translates to:
  /// **'Up to 100x leverage'**
  String get upTo100xLeverage;

  /// No description provided for @tradeOnYourKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Trade on your knowledge'**
  String get tradeOnYourKnowledge;

  /// No description provided for @cryptoWinterQuestion.
  ///
  /// In en, this message translates to:
  /// **'Crypto Winter is coming?'**
  String get cryptoWinterQuestion;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @alphaTokens.
  ///
  /// In en, this message translates to:
  /// **'Alpha tokens'**
  String get alphaTokens;

  /// No description provided for @trustPremium.
  ///
  /// In en, this message translates to:
  /// **'Trust Premium'**
  String get trustPremium;

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up'**
  String get levelUp;

  /// No description provided for @unlockExclusiveRewards.
  ///
  /// In en, this message translates to:
  /// **'Unlock exclusive rewards'**
  String get unlockExclusiveRewards;

  /// No description provided for @welcomeToTrustPremium.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Trust Premium'**
  String get welcomeToTrustPremium;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get begin;

  /// No description provided for @useEarnLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Use. Earn. Level Up'**
  String get useEarnLevelUp;

  /// No description provided for @trustPremiumOnboardingGoldDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete tasks inside Trust Premium to earn XP. Level up and unlock rewards as you go.\n\nBronze -> Silver -> Gold\n\nHigher tiers = more perks, better access.'**
  String get trustPremiumOnboardingGoldDescription;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @boostWithTwt.
  ///
  /// In en, this message translates to:
  /// **'Boost With TWT'**
  String get boostWithTwt;

  /// No description provided for @boostWithTwtDescription.
  ///
  /// In en, this message translates to:
  /// **'Hold or lock TWT to multiply your XP and climb levels faster. Your loyalty now powers your wallet and token growth.'**
  String get boostWithTwtDescription;

  /// No description provided for @keepMovingToKeepYourTier.
  ///
  /// In en, this message translates to:
  /// **'Keep moving to keep your tier'**
  String get keepMovingToKeepYourTier;

  /// No description provided for @trustPremiumKeepActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'We track your XP and locked TWT over the last 14 days. Keep up your progress to maintain your level — you\'ll have 14 days before it resets.'**
  String get trustPremiumKeepActiveDescription;

  /// No description provided for @earnSection.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get earnSection;

  /// No description provided for @pastPerformanceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Past performance is not a reliable indicator of future results. Data source is from CoinMarketCap. '**
  String get pastPerformanceDisclaimer;

  /// No description provided for @subjectToTerms.
  ///
  /// In en, this message translates to:
  /// **'Subject to our Terms'**
  String get subjectToTerms;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @addressBook.
  ///
  /// In en, this message translates to:
  /// **'Address Book'**
  String get addressBook;

  /// No description provided for @syncToExtension.
  ///
  /// In en, this message translates to:
  /// **'Sync to Extension'**
  String get syncToExtension;

  /// No description provided for @trustHandles.
  ///
  /// In en, this message translates to:
  /// **'Trust handles'**
  String get trustHandles;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQrCode;

  /// No description provided for @walletConnect.
  ///
  /// In en, this message translates to:
  /// **'WalletConnect'**
  String get walletConnect;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @englishUnitedKingdom.
  ///
  /// In en, this message translates to:
  /// **'English (United Kingdom)'**
  String get englishUnitedKingdom;

  /// No description provided for @dappBrowser.
  ///
  /// In en, this message translates to:
  /// **'DApp Browser'**
  String get dappBrowser;

  /// No description provided for @nodeSetting.
  ///
  /// In en, this message translates to:
  /// **'Node Setting'**
  String get nodeSetting;

  /// No description provided for @unlockUixos.
  ///
  /// In en, this message translates to:
  /// **'Unlock UIXOs'**
  String get unlockUixos;

  /// No description provided for @passcode.
  ///
  /// In en, this message translates to:
  /// **'Passcode'**
  String get passcode;

  /// No description provided for @autoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get autoLock;

  /// No description provided for @lockMethod.
  ///
  /// In en, this message translates to:
  /// **'Lock method'**
  String get lockMethod;

  /// No description provided for @transactionSigning.
  ///
  /// In en, this message translates to:
  /// **'Transaction signing'**
  String get transactionSigning;

  /// No description provided for @askApprovalAheadTransactions.
  ///
  /// In en, this message translates to:
  /// **'Ask for approval ahead of transactions.'**
  String get askApprovalAheadTransactions;

  /// No description provided for @immediate.
  ///
  /// In en, this message translates to:
  /// **'Immediate'**
  String get immediate;

  /// No description provided for @leaveMoreThan1Minute.
  ///
  /// In en, this message translates to:
  /// **'Leave for more than 1 minute'**
  String get leaveMoreThan1Minute;

  /// No description provided for @leaveMoreThan5Minute.
  ///
  /// In en, this message translates to:
  /// **'Leave for more than 5 minute'**
  String get leaveMoreThan5Minute;

  /// No description provided for @leaveMoreThan1Hour.
  ///
  /// In en, this message translates to:
  /// **'Leave for more than 1 hour'**
  String get leaveMoreThan1Hour;

  /// No description provided for @leaveMoreThan5Hour.
  ///
  /// In en, this message translates to:
  /// **'Leave for more than 5 hour'**
  String get leaveMoreThan5Hour;

  /// No description provided for @selectNetwork.
  ///
  /// In en, this message translates to:
  /// **'Select network'**
  String get selectNetwork;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @multiCoinWallet.
  ///
  /// In en, this message translates to:
  /// **'Multi-coin wallet'**
  String get multiCoinWallet;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @noWalletsFound.
  ///
  /// In en, this message translates to:
  /// **'No wallets found'**
  String get noWalletsFound;

  /// No description provided for @addWallet.
  ///
  /// In en, this message translates to:
  /// **'Add wallet'**
  String get addWallet;

  /// No description provided for @fundYourWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Fund your wallet'**
  String get fundYourWalletTitle;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @googlePay.
  ///
  /// In en, this message translates to:
  /// **'Google Pay'**
  String get googlePay;

  /// No description provided for @allOptions.
  ///
  /// In en, this message translates to:
  /// **'All options'**
  String get allOptions;

  /// No description provided for @allPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'All payment methods'**
  String get allPaymentMethods;

  /// No description provided for @p2p.
  ///
  /// In en, this message translates to:
  /// **'P2P'**
  String get p2p;

  /// No description provided for @exchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get exchange;

  /// No description provided for @cryptoWallet.
  ///
  /// In en, this message translates to:
  /// **'Crypto wallet'**
  String get cryptoWallet;

  /// No description provided for @selectCrypto.
  ///
  /// In en, this message translates to:
  /// **'Select Crypto'**
  String get selectCrypto;

  /// No description provided for @allNetworks.
  ///
  /// In en, this message translates to:
  /// **'All Networks'**
  String get allNetworks;

  /// No description provided for @top100.
  ///
  /// In en, this message translates to:
  /// **'Top 100'**
  String get top100;

  /// No description provided for @stables.
  ///
  /// In en, this message translates to:
  /// **'Stables'**
  String get stables;

  /// No description provided for @selectMethod.
  ///
  /// In en, this message translates to:
  /// **'Select a method'**
  String get selectMethod;

  /// No description provided for @depositFromBinance.
  ///
  /// In en, this message translates to:
  /// **'Deposit from Binance'**
  String get depositFromBinance;

  /// No description provided for @depositFromCoinbase.
  ///
  /// In en, this message translates to:
  /// **'Deposit from Coinbase'**
  String get depositFromCoinbase;

  /// No description provided for @topUpWallet.
  ///
  /// In en, this message translates to:
  /// **'Top-up Wallet'**
  String get topUpWallet;

  /// No description provided for @availableToKhrPair.
  ///
  /// In en, this message translates to:
  /// **'Available to KHR pair'**
  String get availableToKhrPair;

  /// No description provided for @allCrypto.
  ///
  /// In en, this message translates to:
  /// **'All crypto'**
  String get allCrypto;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @noCryptocurrenciesFound.
  ///
  /// In en, this message translates to:
  /// **'No cryptocurrencies found'**
  String get noCryptocurrenciesFound;

  /// No description provided for @receivingPayment.
  ///
  /// In en, this message translates to:
  /// **'Receiving payment'**
  String get receivingPayment;

  /// No description provided for @secretPhrase.
  ///
  /// In en, this message translates to:
  /// **'Secret phrase'**
  String get secretPhrase;

  /// No description provided for @showDetails.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get showDetails;

  /// No description provided for @swift.
  ///
  /// In en, this message translates to:
  /// **'Swift'**
  String get swift;

  /// No description provided for @beta.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get beta;

  /// No description provided for @walletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get walletName;

  /// No description provided for @typically12Words.
  ///
  /// In en, this message translates to:
  /// **'Typically 12 (sometimes 18, 24) words separated by single spaces.'**
  String get typically12Words;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @restoreWallet.
  ///
  /// In en, this message translates to:
  /// **'Restore wallet'**
  String get restoreWallet;

  /// No description provided for @whatIsSecretPhrase.
  ///
  /// In en, this message translates to:
  /// **'What is a secret phrase?'**
  String get whatIsSecretPhrase;

  /// No description provided for @noAssetsFound.
  ///
  /// In en, this message translates to:
  /// **'No assets found'**
  String get noAssetsFound;

  /// No description provided for @addressCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get addressCopiedToClipboard;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @memeTokensDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Meme tokens can be fun but also volatile. Always do your own research and trade carefully.'**
  String get memeTokensDisclaimer;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @tradePerps.
  ///
  /// In en, this message translates to:
  /// **'Trade Perps'**
  String get tradePerps;

  /// No description provided for @tradePerpsDescription.
  ///
  /// In en, this message translates to:
  /// **'Trade on an asset\'s future price movements. Add funds to get started.'**
  String get tradePerpsDescription;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @markets.
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get markets;

  /// No description provided for @noMarketsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No markets available'**
  String get noMarketsAvailable;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @holders.
  ///
  /// In en, this message translates to:
  /// **'Holders'**
  String get holders;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @mcap.
  ///
  /// In en, this message translates to:
  /// **'MCap'**
  String get mcap;

  /// No description provided for @positionsValueUsd.
  ///
  /// In en, this message translates to:
  /// **'Positions value (USD)'**
  String get positionsValueUsd;

  /// No description provided for @viewMyPositions.
  ///
  /// In en, this message translates to:
  /// **'View my positions'**
  String get viewMyPositions;

  /// No description provided for @searchMarkets.
  ///
  /// In en, this message translates to:
  /// **'Search markets'**
  String get searchMarkets;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @trendingTokens.
  ///
  /// In en, this message translates to:
  /// **'Trending tokens'**
  String get trendingTokens;

  /// No description provided for @availableToCurrencyPair.
  ///
  /// In en, this message translates to:
  /// **'Available to {currency} pair'**
  String availableToCurrencyPair(String currency);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noCryptocurrenciesFoundReceive.
  ///
  /// In en, this message translates to:
  /// **'No cryptocurrencies found'**
  String get noCryptocurrenciesFoundReceive;

  /// No description provided for @tokenDetailHoldings.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get tokenDetailHoldings;

  /// No description provided for @tokenDetailHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tokenDetailHistory;

  /// No description provided for @tokenDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tokenDetailAbout;

  /// No description provided for @tokenDetailInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get tokenDetailInsights;

  /// No description provided for @myBalance.
  ///
  /// In en, this message translates to:
  /// **'My balance'**
  String get myBalance;

  /// No description provided for @recharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get recharge;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @bandwidth.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth'**
  String get bandwidth;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @tokenDetailTronBanner.
  ///
  /// In en, this message translates to:
  /// **'You can now earn TRON Energy and Bandwidth Points with TRX to save on gas fees for TRON transactions.'**
  String get tokenDetailTronBanner;

  /// No description provided for @timeRange1H.
  ///
  /// In en, this message translates to:
  /// **'1H'**
  String get timeRange1H;

  /// No description provided for @timeRange1D.
  ///
  /// In en, this message translates to:
  /// **'1D'**
  String get timeRange1D;

  /// No description provided for @timeRange1W.
  ///
  /// In en, this message translates to:
  /// **'1W'**
  String get timeRange1W;

  /// No description provided for @timeRange1M.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get timeRange1M;

  /// No description provided for @timeRange1Y.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get timeRange1Y;

  /// No description provided for @tokenHistoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get tokenHistoryFilter;

  /// No description provided for @tokenHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Transaction records are displayed here.'**
  String get tokenHistoryEmptyMessage;

  /// No description provided for @tokenHistoryCantFindViewBrowser.
  ///
  /// In en, this message translates to:
  /// **'Cannot find your transaction? '**
  String get tokenHistoryCantFindViewBrowser;

  /// No description provided for @tokenHistoryViewBrowser.
  ///
  /// In en, this message translates to:
  /// **'View browser'**
  String get tokenHistoryViewBrowser;

  /// No description provided for @tokenHistoryBuyUsdt.
  ///
  /// In en, this message translates to:
  /// **'Buy USDT'**
  String get tokenHistoryBuyUsdt;

  /// No description provided for @tokenInsightsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tokenInsightsOverview;

  /// No description provided for @tokenInsightsRefreshesIn.
  ///
  /// In en, this message translates to:
  /// **'Refreshes in {time}'**
  String tokenInsightsRefreshesIn(String time);

  /// No description provided for @tokenInsightsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI-generated insights may be inaccurate. The above does not constitute financial advice. Please do your own research.'**
  String get tokenInsightsDisclaimer;

  /// No description provided for @tokenInsightsHeadlineSample.
  ///
  /// In en, this message translates to:
  /// **'🚀 TRON Joins Mastercard Crypto Program as USDT Hits \$85B Milestone 💎'**
  String get tokenInsightsHeadlineSample;

  /// No description provided for @tokenInsightsSummarySample.
  ///
  /// In en, this message translates to:
  /// **'TRON announced joining Mastercard\'s Crypto Partner Program to boost onchain payments, bridging digital assets with traditional finance for cross-border remittances & B2B transfers. 🔥 \$85B USDT now circulates on network, powering real-world activity. AlliumLabs report spotlights TRON in global payments. Tron Inc. scooped 168K more TRX for treasury. Stablecoin dominance & revenue lead signal strong adoption push! 📈'**
  String get tokenInsightsSummarySample;

  /// No description provided for @tokenDetailStablecoinDescription.
  ///
  /// In en, this message translates to:
  /// **'{symbol} is a cryptocurrency with a value pegged close to \$1.00. It is commonly used as a stable asset for trading and transfers.'**
  String tokenDetailStablecoinDescription(String symbol);

  /// No description provided for @tokenDetailDyorWarning.
  ///
  /// In en, this message translates to:
  /// **'Please note, Tether ({symbol}) may not be fully supported. Do your own research (DYOR).'**
  String tokenDetailDyorWarning(String symbol);

  /// No description provided for @tokenDetailStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tokenDetailStats;

  /// No description provided for @tokenDetailMarketCap.
  ///
  /// In en, this message translates to:
  /// **'Market cap'**
  String get tokenDetailMarketCap;

  /// No description provided for @tokenDetailCirculatingSupply.
  ///
  /// In en, this message translates to:
  /// **'Circulating supply'**
  String get tokenDetailCirculatingSupply;

  /// No description provided for @tokenDetailTotalSupply.
  ///
  /// In en, this message translates to:
  /// **'Total supply'**
  String get tokenDetailTotalSupply;

  /// No description provided for @tokenDetailContractAddress.
  ///
  /// In en, this message translates to:
  /// **'Contract address'**
  String get tokenDetailContractAddress;

  /// No description provided for @tokenDetailLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get tokenDetailLinks;

  /// No description provided for @tokenDetailLinkWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get tokenDetailLinkWebsite;

  /// No description provided for @tokenDetailLinkBrowser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get tokenDetailLinkBrowser;

  /// No description provided for @tokenDetailLinkWhitepaper.
  ///
  /// In en, this message translates to:
  /// **'Whitepaper'**
  String get tokenDetailLinkWhitepaper;

  /// No description provided for @tokenDetailLinkX.
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get tokenDetailLinkX;

  /// No description provided for @tokenDetailLinkReddit.
  ///
  /// In en, this message translates to:
  /// **'reddit'**
  String get tokenDetailLinkReddit;

  /// No description provided for @tokenDetailNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get tokenDetailNoData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko', 'pt', 'ru', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
