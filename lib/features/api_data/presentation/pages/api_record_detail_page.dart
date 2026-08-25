import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';

class ApiRecordDetailPage extends StatelessWidget {
  const ApiRecordDetailPage({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.fields,
    this.subtitle,
    this.badges = const <Widget>[],
    this.extraSections = const <Widget>[],
  });

  final String appBarTitle;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final List<MapEntry<String, String>> fields;
  final List<Widget> badges;
  final List<Widget> extraSections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.small,
            AppSpacing.large,
            110,
          ),
          children: <Widget>[
            _DetailHeader(
              title: title,
              subtitle: subtitle,
              icon: icon,
              accentColor: accentColor,
              badges: badges,
            ),
            const SizedBox(height: AppSpacing.medium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.fact_check_outlined,
                          size: 18,
                          color: accentColor,
                        ),
                        const SizedBox(width: AppSpacing.xSmall),
                        Expanded(
                          child: Text(
                            'Detail Data',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    if (fields.isEmpty)
                      const _EmptyDetailText()
                    else
                      _DetailTable(fields: fields),
                  ],
                ),
              ),
            ),
            if (extraSections.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.medium),
              ...extraSections,
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.badges,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final List<Widget> badges;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            accentColor.withValues(alpha: 0.92),
            AppColors.primaryRed.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.90),
              ),
            ),
          ],
          if (badges.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: badges,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailTable extends StatelessWidget {
  const _DetailTable({required this.fields});

  final List<MapEntry<String, String>> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double labelWidth = constraints.maxWidth < 360 ? 104 : 132;

        return Table(
          columnWidths: <int, TableColumnWidth>{
            0: FixedColumnWidth(labelWidth),
            1: const FixedColumnWidth(18),
            2: const FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: fields.map((MapEntry<String, String> field) {
            return TableRow(
              children: <Widget>[
                _DetailCell(
                  text: field.key,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                _DetailCell(
                  text: ':',
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
                _DetailCell(
                  text: field.value,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class _DetailCell extends StatelessWidget {
  const _DetailCell({
    required this.text,
    required this.color,
    required this.fontWeight,
  });

  final String text;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: color, fontWeight: fontWeight),
      ),
    );
  }
}

class _EmptyDetailText extends StatelessWidget {
  const _EmptyDetailText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tidak ada detail yang dapat ditampilkan.',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
