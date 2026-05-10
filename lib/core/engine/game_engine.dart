import 'dart:math';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';

/// Power-up types created by special matches
enum PowerUpType {
  none,
  directional, // Match 4 line
  radial, // Match 4 L/T
  eraser, // Match 5 line
  superBomb, // Match 6+
}

/// Represents a single sushi element on the grid
class SushiElement {
  final SushiType type;
  final PowerUpType powerUp;
  final bool isHighlighted;

  const SushiElement({
    required this.type,
    this.powerUp = PowerUpType.none,
    this.isHighlighted = false,
  });

  SushiElement copyWith({
    SushiType? type,
    PowerUpType? powerUp,
    bool? isHighlighted,
  }) {
    return SushiElement(
      type: type ?? this.type,
      powerUp: powerUp ?? this.powerUp,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SushiElement &&
        other.type == type &&
        other.powerUp == powerUp;
  }

  @override
  int get hashCode => type.hashCode ^ powerUp.hashCode;
}

/// Represents a position on the grid
class GridPosition {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridPosition && other.row == row && other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

/// Represents a match found on the grid
enum MatchType {
  normal, // 3 in a row
  lShape, // L shape - 4 tiles
  tShape, // T shape - 4 tiles
  line4, // 4 in a line
  line5, // 5 in a line
  line6Plus, // 6+ in a line
}

class Match {
  final List<GridPosition> positions;
  final SushiType type;
  final int comboMultiplier;
  final MatchType matchType;

  const Match({
    required this.positions,
    required this.type,
    this.comboMultiplier = 1,
    this.matchType = MatchType.normal,
  });

  int get length => positions.length;

  /// Multiplier based on match type
  int get typeMultiplier {
    switch (matchType) {
      case MatchType.line4:
        return 2;
      case MatchType.lShape:
      case MatchType.tShape:
        return 3;
      case MatchType.line5:
        return 4;
      case MatchType.line6Plus:
        return 5;
      case MatchType.normal:
        return 1;
    }
  }

  bool get createsPowerUp {
    return length >= 4;
  }

  PowerUpType get createdPowerUp {
    if (length >= 6) return PowerUpType.superBomb;
    if (length == 5) return PowerUpType.eraser;
    if (length == 4) {
      return PowerUpType.radial;
    }
    return PowerUpType.none;
  }

  int get baseScore => type.score * length * comboMultiplier * typeMultiplier;
}

/// Grid configuration with difficulty control
class GridConfig {
  final int rows;
  final int cols;
  final int sushiTypeCount; // Fewer types = easier matches

  const GridConfig({
    this.rows = 8,
    this.cols = 8,
    this.sushiTypeCount = 8,
  });
}

/// Result of gravity application
class CascadeResult {
  final List<List<SushiElement>> grid;
  final List<Match> matches;
  final int scoreGained;
  final bool hasMoreCascades;

  const CascadeResult({
    required this.grid,
    required this.matches,
    required this.scoreGained,
    required this.hasMoreCascades,
  });
}

/// Hint result
class HintResult {
  final GridPosition from;
  final GridPosition to;
  final int estimatedScore;

  const HintResult({
    required this.from,
    required this.to,
    required this.estimatedScore,
  });
}

/// Main Game Engine
class GameEngine {
  final Random _random = Random();
  GridConfig _config;
  late List<List<SushiElement>> _grid;

  GameEngine({GridConfig config = const GridConfig()}) : _config = config;

  GridConfig get config => _config;

  /// Get active sushi types based on difficulty (fewer types = easier)
  List<SushiType> _getActiveSushiTypes() {
    return SushiType.values.take(_config.sushiTypeCount).toList();
  }

  /// Random sushi type from active types only
  SushiType _randomSushiType() {
    final types = _getActiveSushiTypes();
    return types[_random.nextInt(types.length)];
  }

  /// Initialize grid with random elements (using only allowed sushi types)
  void initGrid() {
    final types = _getActiveSushiTypes();
    _grid = List.generate(
      _config.rows,
      (_) => List.generate(
        _config.cols,
        (_) => SushiElement(type: types[_random.nextInt(types.length)]),
      ),
    );

    // Ensure no initial matches and has valid moves
    int attempts = 0;
    while ((detectMatches().isNotEmpty || !hasValidMoves()) && attempts < 100) {
      _grid = List.generate(
        _config.rows,
        (_) => List.generate(
          _config.cols,
          (_) => SushiElement(type: types[_random.nextInt(types.length)]),
        ),
      );
      attempts++;
    }
  }

  /// Get current grid
  List<List<SushiElement>> get grid => _grid;

  /// Set custom grid (for testing)
  void setGrid(List<List<SushiElement>> grid) {
    _grid = grid;
  }

  /// Swap two elements
  bool swap(GridPosition from, GridPosition to) {
    if (!_isValidPosition(from) || !_isValidPosition(to)) return false;

    // Check if adjacent
    final rowDiff = (from.row - to.row).abs();
    final colDiff = (from.col - to.col).abs();
    if (rowDiff + colDiff != 1) return false;

    // Swap
    final temp = _grid[from.row][from.col];
    _grid[from.row][from.col] = _grid[to.row][to.col];
    _grid[to.row][to.col] = temp;

    // Check if swap creates a match
    final matches = detectMatches();
    if (matches.isEmpty) {
      // Swap back
      _grid[to.row][to.col] = _grid[from.row][from.col];
      _grid[from.row][from.col] = temp;
      return false;
    }

    return true;
  }

  /// Check if position is valid
  bool _isValidPosition(GridPosition pos) {
    return pos.row >= 0 &&
        pos.row < _config.rows &&
        pos.col >= 0 &&
        pos.col < _config.cols;
  }

  /// Detect all matches on the grid
  List<Match> detectMatches() {
    final matches = <Match>[];

    // Check horizontal matches
    for (int row = 0; row < _config.rows; row++) {
      for (int col = 0; col < _config.cols - 2; col++) {
        final type = _grid[row][col].type;
        int matchLength = 1;

        while (col + matchLength < _config.cols &&
            _grid[row][col + matchLength].type == type) {
          matchLength++;
        }

        if (matchLength >= 3) {
          final positions = List.generate(
            matchLength,
            (i) => GridPosition(row, col + i),
          );
          matches.add(Match(positions: positions, type: type));
          col += matchLength - 1;
        }
      }
    }

    // Check vertical matches
    for (int col = 0; col < _config.cols; col++) {
      for (int row = 0; row < _config.rows - 2; row++) {
        final type = _grid[row][col].type;
        int matchLength = 1;

        while (row + matchLength < _config.rows &&
            _grid[row + matchLength][col].type == type) {
          matchLength++;
        }

        if (matchLength >= 3) {
          final positions = List.generate(
            matchLength,
            (i) => GridPosition(row + i, col),
          );
          matches.add(Match(positions: positions, type: type));
          row += matchLength - 1;
        }
      }
    }

    return matches;
  }

  /// Apply gravity and fill empty spaces
  CascadeResult applyGravity({int comboMultiplier = 1}) {
    final matches = detectMatches();
    if (matches.isEmpty) {
      return CascadeResult(
        grid: _grid,
        matches: [],
        scoreGained: 0,
        hasMoreCascades: false,
      );
    }

    int totalScore = 0;
    final matchedPositions = <GridPosition>{};

    // Calculate scores and mark matched positions
    for (final match in matches) {
      totalScore += match.baseScore;
      matchedPositions.addAll(match.positions);
    }

    // Apply gravity - move elements down
    for (int col = 0; col < _config.cols; col++) {
      int writeRow = _config.rows - 1;

      for (int row = _config.rows - 1; row >= 0; row--) {
        if (!matchedPositions.contains(GridPosition(row, col))) {
          _grid[writeRow][col] = _grid[row][col];
          writeRow--;
        }
      }

      // Fill empty spaces with new elements
      for (int row = writeRow; row >= 0; row--) {
        _grid[row][col] = SushiElement(type: _randomSushiType());
      }
    }

    // Check for more cascades
    final hasMore = detectMatches().isNotEmpty;

    return CascadeResult(
      grid: _grid,
      matches: matches,
      scoreGained: totalScore,
      hasMoreCascades: hasMore,
    );
  }

  /// Process a complete turn (swap + cascade + combos)
  Future<CascadeResult> processTurn(
    GridPosition from,
    GridPosition to,
  ) async {
    // Perform swap
    if (!swap(from, to)) {
      return CascadeResult(
        grid: _grid,
        matches: [],
        scoreGained: 0,
        hasMoreCascades: false,
      );
    }

    // Apply gravity with cascading
    int combo = 1;
    var result = applyGravity(comboMultiplier: combo);
    var totalScore = result.scoreGained;

    // Continue cascading while there are matches
    while (result.hasMoreCascades) {
      combo++;
      await Future.delayed(const Duration(milliseconds: 200));
      result = applyGravity(comboMultiplier: combo);
      totalScore += result.scoreGained;
    }

    return CascadeResult(
      grid: _grid,
      matches: result.matches,
      scoreGained: totalScore,
      hasMoreCascades: false,
    );
  }

  /// Check if there are valid moves
  bool hasValidMoves() {
    for (int row = 0; row < _config.rows; row++) {
      for (int col = 0; col < _config.cols; col++) {
        // Check right swap
        if (col < _config.cols - 1) {
          _swapInternal(row, col, row, col + 1);
          if (detectMatches().isNotEmpty) {
            _swapInternal(row, col, row, col + 1);
            return true;
          }
          _swapInternal(row, col, row, col + 1);
        }

        // Check down swap
        if (row < _config.rows - 1) {
          _swapInternal(row, col, row + 1, col);
          if (detectMatches().isNotEmpty) {
            _swapInternal(row, col, row + 1, col);
            return true;
          }
          _swapInternal(row, col, row + 1, col);
        }
      }
    }
    return false;
  }

  void _swapInternal(int r1, int c1, int r2, int c2) {
    final temp = _grid[r1][c1];
    _grid[r1][c1] = _grid[r2][c2];
    _grid[r2][c2] = temp;
  }

  /// Shuffle grid when no valid moves
  void shuffleGrid() {
    int attempts = 0;
    do {
      final elements = _grid.expand((row) => row).toList();
      elements.shuffle(_random);

      int i = 0;
      for (int row = 0; row < _config.rows; row++) {
        for (int col = 0; col < _config.cols; col++) {
          _grid[row][col] = elements[i++];
        }
      }
      attempts++;
    } while ((detectMatches().isNotEmpty || !hasValidMoves()) && attempts < 50);
  }

  /// Get a hint for the player
  HintResult? getHint() {
    for (int row = 0; row < _config.rows; row++) {
      for (int col = 0; col < _config.cols; col++) {
        // Check right swap
        if (col < _config.cols - 1) {
          _swapInternal(row, col, row, col + 1);
          final matches = detectMatches();
          if (matches.isNotEmpty) {
            _swapInternal(row, col, row, col + 1);
            final estimatedScore = matches.fold<int>(
              0,
              (sum, match) => sum + match.baseScore,
            );
            return HintResult(
              from: GridPosition(row, col),
              to: GridPosition(row, col + 1),
              estimatedScore: estimatedScore,
            );
          }
          _swapInternal(row, col, row, col + 1);
        }

        // Check down swap
        if (row < _config.rows - 1) {
          _swapInternal(row, col, row + 1, col);
          final matches = detectMatches();
          if (matches.isNotEmpty) {
            _swapInternal(row, col, row + 1, col);
            final estimatedScore = matches.fold<int>(
              0,
              (sum, match) => sum + match.baseScore,
            );
            return HintResult(
              from: GridPosition(row, col),
              to: GridPosition(row + 1, col),
              estimatedScore: estimatedScore,
            );
          }
          _swapInternal(row, col, row + 1, col);
        }
      }
    }
    return null;
  }

  /// Calculate score for given matches
  int calculateScore(List<Match> matches, int combo) {
    int total = 0;
    for (final match in matches) {
      total += match.baseScore;
    }
    return total;
  }
}