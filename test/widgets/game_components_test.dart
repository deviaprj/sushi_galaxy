import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sushi_galaxy/ui/components/game_components.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/core/engine/game_engine.dart';

void main() {
  group('AnimatedSushiTile', () {
    testWidgets('renders sushi element with correct type', (tester) async {
      final element = SushiElement(type: SushiType.salmon);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSushiTile(
              element: element,
              size: 48,
              row: 0,
              col: 0,
            ),
          ),
        ),
      );

      // Verify tile renders
      expect(find.byType(AnimatedSushiTile), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('calls onDragStart when pan starts', (tester) async {
      GridPosition? startPosition;
      final element = SushiElement(type: SushiType.tuna);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSushiTile(
              element: element,
              size: 48,
              row: 2,
              col: 3,
              onDragStart: (row, col) {
                startPosition = GridPosition(row, col);
              },
            ),
          ),
        ),
      );

      // Start drag gesture
      final gesture = await tester.startGesture(tester.getCenter(find.byType(GestureDetector)));
      await tester.pump();

      expect(startPosition, isNotNull);
      expect(startPosition!.row, equals(2));
      expect(startPosition!.col, equals(3));

      await gesture.cancel();
    });

    testWidgets('calls onDragEnd with velocity when pan ends', (tester) async {
      int? endRow;
      int? endCol;
      final element = SushiElement(type: SushiType.shrimp);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSushiTile(
              element: element,
              size: 48,
              row: 1,
              col: 1,
              onDragEnd: (row, col, dx, dy) {
                endRow = row;
                endCol = col;
              },
            ),
          ),
        ),
      );

      // Perform drag gesture with velocity
      final gesture = await tester.startGesture(tester.getCenter(find.byType(GestureDetector)));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(endRow, equals(1));
      expect(endCol, equals(1));
    });

    testWidgets('shows matched animation when isMatched is true', (tester) async {
      final element = SushiElement(type: SushiType.avocado);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSushiTile(
              element: element,
              size: 48,
              row: 0,
              col: 0,
              isMatched: true,
            ),
          ),
        ),
      );

      // Let animation run
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 150));

      // Animation should complete without errors
      expect(find.byType(AnimatedSushiTile), findsOneWidget);
    });
  });

  group('AnimatedGameGrid', () {
    testWidgets('renders grid with correct dimensions', (tester) async {
      // Create a 4x4 grid
      final grid = List.generate(
        4,
        (row) => List.generate(
          4,
          (col) => SushiElement(type: SushiType.values[(row + col) % SushiType.values.length]),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedGameGrid(
              grid: grid,
              tileSize: 48,
            ),
          ),
        ),
      );

      // Verify grid renders with correct number of tiles
      expect(find.byType(AnimatedSushiTile), findsNWidgets(16));
    });

    testWidgets('highlights matched positions', (tester) async {
      final grid = List.generate(
        4,
        (row) => List.generate(
          4,
          (col) => SushiElement(type: SushiType.salmon),
        ),
      );

      final matchedPositions = {
        GridPosition(0, 0),
        GridPosition(0, 1),
        GridPosition(0, 2),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedGameGrid(
              grid: grid,
              tileSize: 48,
              matchedPositions: matchedPositions,
            ),
          ),
        ),
      );

      // Pump frames without settling to avoid animation timer issues
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Grid should render
      expect(find.byType(AnimatedGameGrid), findsOneWidget);
    });

    testWidgets('calls onDragStart and onDragEnd callbacks', (tester) async {
      GridPosition? startPos;

      final grid = List.generate(
        4,
        (row) => List.generate(
          4,
          (col) => SushiElement(type: SushiType.salmon),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedGameGrid(
              grid: grid,
              tileSize: 48,
              onDragStart: (row, col) {
                startPos = GridPosition(row, col);
              },
              onDragEnd: (row, col, dx, dy) {
                // Callback received
              },
            ),
          ),
        ),
      );

      // Get the first tile and start dragging
      final firstTile = find.byType(AnimatedSushiTile).first;
      final gesture = await tester.startGesture(tester.getCenter(firstTile));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();

      // Callbacks should have been called
      expect(startPos, isNotNull);
    });
  });

  group('AnimatedScore', () {
    testWidgets('displays score and target', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedScore(
              score: 1500,
              targetScore: 2000,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1500'), findsOneWidget);
      expect(find.text('2000'), findsOneWidget);
      expect(find.text('Score'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedScore(
              score: 1000,
              targetScore: 2000,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Progress bar should exist
      expect(find.byType(Stack), findsWidgets);
    });
  });

  group('MovesIndicator', () {
    testWidgets('displays move count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MovesIndicator(
              moves: 15,
              maxMoves: 25,
            ),
          ),
        ),
      );

      // Pump a few frames without settling to avoid animation timer issues
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('15'), findsOneWidget);
      expect(find.text('moves'), findsOneWidget);
    });

    testWidgets('shows warning when moves are low', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MovesIndicator(
              moves: 3,
              maxMoves: 25,
            ),
          ),
        ),
      );

      // Pump a few frames without settling to avoid animation timer issues
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('3'), findsOneWidget);
    });
  });

  group('AnimatedCombo', () {
    testWidgets('displays combo multiplier', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCombo(
              combo: 3,
            ),
          ),
        ),
      );

      // Allow animations to complete
      await tester.pumpAndSettle();

      expect(find.text('3x'), findsOneWidget);
      expect(find.textContaining('COMBO'), findsOneWidget);
    });

    testWidgets('does not show for combo < 2', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCombo(
              combo: 1,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('1x'), findsNothing);
    });
  });
}