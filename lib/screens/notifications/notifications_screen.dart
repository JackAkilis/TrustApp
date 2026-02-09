import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_helper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _enableNotifications = false;
  bool _sendAndReceive = false;
  bool _marketUpdates = true;
  bool _promotionsGiveaways = true;
  bool _productAnnouncements = true;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryTextColor = ThemeHelper.getSecondaryTextColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Enable notifications
          _buildNotificationItem(
            context: context,
            title: 'Enable notifications',
            textColor: textColor,
            trailing: Switch(
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                  // If disabled, turn off all other notifications
                  if (!value) {
                    _sendAndReceive = false;
                    _marketUpdates = false;
                    _promotionsGiveaways = false;
                    _productAnnouncements = false;
                  }
                });
              },
              activeColor: primaryColor,
            ),
          ),
          // Price Alerts
          _buildNotificationItem(
            context: context,
            title: 'Price Alerts',
            value: 'Disabled',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          // Send and receive
          _buildNotificationItem(
            context: context,
            title: 'Send and receive',
            subtitle: 'Alerts when you send or receive crypto',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            trailing: Switch(
              value: _sendAndReceive && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) {
                      setState(() {
                        _sendAndReceive = value;
                      });
                    }
                  : null,
              activeColor: primaryColor,
            ),
          ),
          // Market updates
          _buildNotificationItem(
            context: context,
            title: 'Market updates',
            subtitle: 'Stay informed on major market moves',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            trailing: Switch(
              value: _marketUpdates && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) {
                      setState(() {
                        _marketUpdates = value;
                      });
                    }
                  : null,
              activeColor: primaryColor,
            ),
          ),
          // Promotions & Giveaways
          _buildNotificationItem(
            context: context,
            title: 'Promotions & Giveaways',
            subtitle: 'Alerts for giveaways and rewards',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            trailing: Switch(
              value: _promotionsGiveaways && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) {
                      setState(() {
                        _promotionsGiveaways = value;
                      });
                    }
                  : null,
              activeColor: primaryColor,
            ),
          ),
          // Product announcements
          _buildNotificationItem(
            context: context,
            title: 'Product announcements',
            subtitle: 'Be the first to know about new features',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            trailing: Switch(
              value: _productAnnouncements && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) {
                      setState(() {
                        _productAnnouncements = value;
                      });
                    }
                  : null,
              activeColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required String title,
    String? value,
    String? subtitle,
    required Color textColor,
    Color? secondaryTextColor,
    Widget? trailing,
  }) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final itemSecondaryTextColor = secondaryTextColor ?? ThemeHelper.getSecondaryTextColor(context);

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: itemSecondaryTextColor,
                    ),
                  ),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: itemSecondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
