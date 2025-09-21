import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/responsive_builder.dart';

void main() {
  group('ResponsiveUtils Tests', () {
    test('should categorize mobile screen sizes correctly', () {
      expect(ResponsiveUtils.getScreenSize(599), equals(ScreenSize.mobile));
      expect(ResponsiveUtils.getScreenSize(600), equals(ScreenSize.tablet));
    });

    test('should categorize tablet screen sizes correctly', () {
      expect(ResponsiveUtils.getScreenSize(839), equals(ScreenSize.tablet));
      expect(ResponsiveUtils.getScreenSize(840), equals(ScreenSize.desktop));
    });

    test('should categorize desktop screen sizes correctly', () {
      expect(ResponsiveUtils.getScreenSize(1199), equals(ScreenSize.desktop));
      expect(ResponsiveUtils.getScreenSize(1200), equals(ScreenSize.large));
    });

    test('should categorize large screen sizes correctly', () {
      expect(ResponsiveUtils.getScreenSize(1599), equals(ScreenSize.large));
      expect(ResponsiveUtils.getScreenSize(1600), equals(ScreenSize.extraLarge));
    });

    test('should identify device types correctly', () {
      // Test mobile detection
      final mobileContext = const _TestContext(Size(400, 800)).getContext();
      expect(ResponsiveUtils.isMobile(mobileContext), isTrue);
      expect(ResponsiveUtils.isTablet(mobileContext), isFalse);
      expect(ResponsiveUtils.isDesktop(mobileContext), isFalse);

      // Test tablet detection
      final tabletContext = const _TestContext(Size(800, 1200)).getContext();
      expect(ResponsiveUtils.isMobile(tabletContext), isFalse);
      expect(ResponsiveUtils.isTablet(tabletContext), isTrue);
      expect(ResponsiveUtils.isDesktop(tabletContext), isFalse);

      // Test desktop detection
      final desktopContext = const _TestContext(Size(1400, 900)).getContext();
      expect(ResponsiveUtils.isMobile(desktopContext), isFalse);
      expect(ResponsiveUtils.isTablet(desktopContext), isFalse);
      expect(ResponsiveUtils.isDesktop(desktopContext), isTrue);
    });

    test('should provide responsive padding', () {
      final mobileContext = const _TestContext(Size(400, 800)).getContext();
      final tabletContext = const _TestContext(Size(800, 600)).getContext();
      final desktopContext = const _TestContext(Size(1400, 900)).getContext();

      final mobilePadding = ResponsiveUtils.getResponsivePadding(mobileContext);
      final tabletPadding = ResponsiveUtils.getResponsivePadding(tabletContext);
      final desktopPadding = ResponsiveUtils.getResponsivePadding(desktopContext);

      expect(mobilePadding, equals(const EdgeInsets.all(16)));
      expect(tabletPadding, equals(const EdgeInsets.all(24)));
      expect(desktopPadding, equals(const EdgeInsets.all(32)));
    });

    test('should provide responsive margin', () {
      final mobileContext = const _TestContext(Size(400, 800)).getContext();
      final tabletContext = const _TestContext(Size(800, 600)).getContext();
      final desktopContext = const _TestContext(Size(1400, 900)).getContext();

      final mobileMargin = ResponsiveUtils.getResponsiveMargin(mobileContext);
      final tabletMargin = ResponsiveUtils.getResponsiveMargin(tabletContext);
      final desktopMargin = ResponsiveUtils.getResponsiveMargin(desktopContext);

      expect(mobileMargin, equals(const EdgeInsets.all(8)));
      expect(tabletMargin, equals(const EdgeInsets.all(12)));
      expect(desktopMargin, equals(const EdgeInsets.all(16)));
    });

    test('should provide max content width', () {
      final mobileContext = const _TestContext(Size(400, 800)).getContext();
      final tabletContext = const _TestContext(Size(800, 600)).getContext();
      final desktopContext = const _TestContext(Size(1400, 900)).getContext();
      final largeContext = const _TestContext(Size(1800, 1000)).getContext();

      expect(ResponsiveUtils.getMaxContentWidth(mobileContext), equals(double.infinity));
      expect(ResponsiveUtils.getMaxContentWidth(tabletContext), equals(720));
      expect(ResponsiveUtils.getMaxContentWidth(desktopContext), equals(1200));
      expect(ResponsiveUtils.getMaxContentWidth(largeContext), equals(1400));
    });

    test('should provide grid columns', () {
      final mobileContext = const _TestContext(Size(400, 800)).getContext();
      final tabletContext = const _TestContext(Size(800, 600)).getContext();
      final desktopContext = const _TestContext(Size(1400, 900)).getContext();
      final largeContext = const _TestContext(Size(1800, 1000)).getContext();

      expect(ResponsiveUtils.getGridColumns(mobileContext), equals(1));
      expect(ResponsiveUtils.getGridColumns(tabletContext), equals(2));
      expect(ResponsiveUtils.getGridColumns(desktopContext), equals(3));
      expect(ResponsiveUtils.getGridColumns(largeContext), equals(4));
    });

    test('should provide card aspect ratio', () {
      final mobileContext = const _TestContext(Size(400, 800)).getContext();
      final tabletContext = const _TestContext(Size(800, 600)).getContext();
      final desktopContext = const _TestContext(Size(1400, 900)).getContext();

      expect(ResponsiveUtils.getCardAspectRatio(mobileContext), equals(1.5));
      expect(ResponsiveUtils.getCardAspectRatio(tabletContext), equals(1.2));
      expect(ResponsiveUtils.getCardAspectRatio(desktopContext), equals(1.0));
    });
  });

  group('ResponsiveBuilder Tests', () {
    testWidgets('should render mobile layout on small screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, screenSize) => Text(screenSize.toString()),
            mobileBuilder: (context, screenSize) => const Text('Mobile'),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      expect(find.text('Mobile'), findsOneWidget);
    });

    testWidgets('should render tablet layout on medium screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, screenSize) => Text(screenSize.toString()),
            tabletBuilder: (context, screenSize) => const Text('Tablet'),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();

      expect(find.text('Tablet'), findsOneWidget);
    });

    testWidgets('should render desktop layout on large screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, screenSize) => Text(screenSize.toString()),
            desktopBuilder: (context, screenSize) => const Text('Desktop'),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(1400, 900));
      await tester.pumpAndSettle();

      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('should fall back to general builder when specific builder is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, screenSize) => const Text('General'),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      expect(find.text('General'), findsOneWidget);
    });
  });

  group('AdaptiveWidget Tests', () {
    testWidgets('should render mobile widget on mobile screens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveWidget(
            mobile: Text('Mobile Widget'),
            tablet: Text('Tablet Widget'),
            desktop: Text('Desktop Widget'),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      expect(find.text('Mobile Widget'), findsOneWidget);
      expect(find.text('Tablet Widget'), findsNothing);
      expect(find.text('Desktop Widget'), findsNothing);
    });

    testWidgets('should render tablet widget on tablet screens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveWidget(
            mobile: Text('Mobile Widget'),
            tablet: Text('Tablet Widget'),
            desktop: Text('Desktop Widget'),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();

      expect(find.text('Mobile Widget'), findsNothing);
      expect(find.text('Tablet Widget'), findsOneWidget);
      expect(find.text('Desktop Widget'), findsNothing);
    });

    testWidgets('should render desktop widget on desktop screens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveWidget(
            mobile: Text('Mobile Widget'),
            tablet: Text('Tablet Widget'),
            desktop: Text('Desktop Widget'),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(1400, 900));
      await tester.pumpAndSettle();

      expect(find.text('Mobile Widget'), findsNothing);
      expect(find.text('Tablet Widget'), findsNothing);
      expect(find.text('Desktop Widget'), findsOneWidget);
    });

    testWidgets('should fall back to mobile when tablet is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveWidget(
            mobile: Text('Mobile Widget'),
            desktop: Text('Desktop Widget'),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();

      expect(find.text('Mobile Widget'), findsOneWidget);
      expect(find.text('Desktop Widget'), findsNothing);
    });
  });

  group('ResponsivePadding Tests', () {
    testWidgets('should apply mobile padding on mobile screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsivePadding(
            mobile: const EdgeInsets.all(8),
            tablet: const EdgeInsets.all(16),
            desktop: const EdgeInsets.all(24),
            child: Container(
              key: const Key('test-container'),
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byKey(const Key('test-container')),
      );
      final padding = tester.widget<Padding>(
        find.ancestor(
          of: find.byKey(const Key('test-container')),
          matching: find.byType(Padding),
        ),
      );

      expect(padding.padding, equals(const EdgeInsets.all(8)));
    });
  });

  group('ResponsiveGrid Tests', () {
    test('should provide correct grid columns for different screen sizes', () {
      final mobileContext = const _TestContext(Size(400, 800)).getContext();
      final tabletContext = const _TestContext(Size(800, 600)).getContext();
      final desktopContext = const _TestContext(Size(1400, 900)).getContext();

      expect(ResponsiveUtils.getGridColumns(mobileContext), equals(1));
      expect(ResponsiveUtils.getGridColumns(tabletContext), equals(2));
      expect(ResponsiveUtils.getGridColumns(desktopContext), equals(3));
    });
  });

  group('ResponsiveExtensions Tests', () {
    testWidgets('should provide screen size extension', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final screenSize = context.screenSize;
              return Text(screenSize.toString());
            },
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      expect(find.text(ScreenSize.mobile.toString()), findsOneWidget);
    });

    testWidgets('should provide device type extension', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final deviceType = context.deviceType;
              return Text(deviceType.toString());
            },
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      expect(find.text(DeviceType.mobile.toString()), findsOneWidget);
    });

    testWidgets('should provide boolean extensions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Column(
                children: [
                  Text('isMobile: ${context.isMobile}'),
                  Text('isTablet: ${context.isTablet}'),
                  Text('isDesktop: ${context.isDesktop}'),
                ],
              );
            },
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      expect(find.text('isMobile: true'), findsOneWidget);
      expect(find.text('isTablet: false'), findsOneWidget);
      expect(find.text('isDesktop: false'), findsOneWidget);
    });
  });
}

// Helper function to create a context with specific size for testing
BuildContext _createContextWithSize(Size size) {
  return _TestContext(size).getContext();
}

// Test context class to provide MediaQuery data
class _TestContext extends StatelessWidget {
  final Size size;

  const _TestContext(this.size);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: Container(),
    );
  }

  BuildContext getContext() {
    final element = createElement();
    element.mount(null, null);
    return element;
  }
}
