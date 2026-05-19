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
    return matchType != MatchType.normal || length >= 4;
  }

  PowerUpType get createdPowerUp {
    if (matchType == MatchType.lShape || matchType == MatchType.tShape) {
      return PowerUpType.radial;
    }
    if (matchType == MatchType.line4) return PowerUpType.directional;
    if (matchType == MatchType.line5) return PowerUpType.eraser;
    if (matchType == MatchType.line6Plus) return PowerUpType.superBomb;
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
  final int comboTier;

  const GridConfig({
    this.rows = 8,
    this.cols = 8,
    this.sushiTypeCount = 8,
    this.comboTier = 0,
  });
}

enum _LineOrientation { horizontal, vertical }

class _RawMatch {
  final List<GridPosition> positions;
  final SushiType type;
  final _LineOrientation orientation;

  const _RawMatch({
    required this.positions,
    required this.type,
    required this.orientation,
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

  /// Picks a type for filling empty slots created by gravity/booster.
  ///
  /// Strategy:
  /// - NEVER place a tile that immediately creates a 3-in-a-row (avoids
  ///   artificially induced auto-chains).
  /// - Among the remaining safe types, choose uniformly at random so that
  ///   the distribution stays balanced.
  /// - Chains can still occur naturally when *existing* tiles fall and happen
  ///   to line up — which is rare (~5-15 % per move) and feels earned.
  SushiType _pickFillType(int row, int col) {
    final types = _getActiveSushiTypes();
    final safe = types.where((t) => !_wouldCreateMatch(row, col, t)).toList();
    final pool = safe.isNotEmpty ? safe : types;
    return pool[_random.nextInt(pool.length)];
  }

  SushiType _pickBiasedType(int row, int col) {
    final types = _getActiveSushiTypes();
    if (_config.comboTier <= 0) {
      return types[_random.nextInt(types.length)];
    }

    final weights = types
        .map((type) => _computeTypeWeight(row, col, type))
        .toList(growable: false);
    final total = weights.fold<double>(0, (sum, weight) => sum + weight);
    var cursor = _random.nextDouble() * total;

    for (var index = 0; index < types.length; index++) {
      cursor -= weights[index];
      if (cursor <= 0) {
        return types[index];
      }
    }

    return types.last;
  }

  double _computeTypeWeight(int row, int col, SushiType type) {
    var weight = 1.0;
    final tier = _config.comboTier.toDouble();

    final left1 = col > 0 ? _grid[row][col - 1].type : null;
    final left2 = col > 1 ? _grid[row][col - 2].type : null;
    final up1 = row > 0 ? _grid[row - 1][col].type : null;
    final up2 = row > 1 ? _grid[row - 2][col].type : null;
    final right1 = col < _config.cols - 1 ? _grid[row][col + 1].type : null;
    final down1 = row < _config.rows - 1 ? _grid[row + 1][col].type : null;

    if (left1 == type) weight += 0.6 + tier * 0.15;
    if (up1 == type) weight += 0.6 + tier * 0.15;
    if (left2 == type) weight += 0.3 + tier * 0.18;
    if (up2 == type) weight += 0.3 + tier * 0.18;

    if (_config.comboTier >= 1 &&
        ((left1 == type && left2 == type) || (up1 == type && up2 == type))) {
      weight += 0.8;
    }

    if (_config.comboTier >= 2) {
      if (left1 == type && right1 == type) weight += 0.9;
      if (up1 == type && down1 == type) weight += 0.9;
    }

    if (_config.comboTier >= 3 &&
        ((left1 == type && up1 == type) ||
            (left1 == type && down1 == type) ||
            (right1 == type && up1 == type) ||
            (right1 == type && down1 == type))) {
      weight += 1.2;
    }

    if (_config.comboTier >= 5) {
      final adjacentCount = [left1, right1, up1, down1]
          .where((neighbor) => neighbor == type)
          .length;
      weight += adjacentCount * 0.25;
    }

    return weight;
  }

  /// Returns true if placing [type] at [row][col] would create a 3-in-a-row
  /// match horizontally (checking 2 cells to the left) or vertically
  /// (checking 2 cells above). Only looks at already-placed cells so it is
  /// safe to call during a left-to-right, top-to-bottom fill pass.
  bool _wouldCreateMatch(int row, int col, SushiType type) {
    // Horizontal: two same types immediately to the left
    if (col >= 2 &&
        _grid[row][col - 1].type == type &&
        _grid[row][col - 2].type == type) return true;
    // Vertical: two same types immediately above
    if (row >= 2 &&
        _grid[row - 1][col].type == type &&
        _grid[row - 2][col].type == type) return true;
    return false;
  }

  /// Initialize grid with random elements (using only allowed sushi types).
  /// Uses greedy placement to guarantee no initial 3-in-a-row matches.
  void initGrid() {
    _grid = List.generate(
      _config.rows,
      (_) => List.generate(
        _config.cols,
        (_) => SushiElement(type: _getActiveSushiTypes().first),
      ),
    );

    final types = _getActiveSushiTypes();

    // Greedy pass: for each cell pick a type that does not create a match
    for (int row = 0; row < _config.rows; row++) {
      for (int col = 0; col < _config.cols; col++) {
        final safe = types.where((t) => !_wouldCreateMatch(row, col, t)).toList();
        final candidates = safe.isNotEmpty ? safe : types;
        _grid[row][col] = SushiElement(type: candidates[_random.nextInt(candidates.length)]);
      }
    }

    // The greedy pass guarantees no matches, so we only need to ensure valid
    // moves exist (extremely rare edge case).
    if (!hasValidMoves()) {
      int attempts = 0;
      do {
        for (int row = 0; row < _config.rows; row++) {
          for (int col = 0; col < _config.cols; col++) {
            final safe = types.where((t) => !_wouldCreateMatch(row, col, t)).toList();
            final candidates = safe.isNotEmpty ? safe : types;
            _grid[row][col] = SushiElement(type: candidates[_random.nextInt(candidates.length)]);
          }
        }
        attempts++;
      } while (!hasValidMoves() && attempts < 50);
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
    final rawMatches = <_RawMatch>[];

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
          rawMatches.add(
            _RawMatch(
              positions: positions,
              type: type,
              orientation: _LineOrientation.horizontal,
            ),
          );
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
          rawMatches.add(
            _RawMatch(
              positions: positions,
              type: type,
              orientation: _LineOrientation.vertical,
            ),
          );
          row += matchLength - 1;
        }
      }
    }

    return _mergeRawMatches(rawMatches);
  }

  List<Match> _mergeRawMatches(List<_RawMatch> rawMatches) {
    final matches = <Match>[];
    final visited = <int>{};

    for (int index = 0; index < rawMatches.length; index++) {
      if (visited.contains(index)) continue;

      final current = rawMatches[index];
      _RawMatch? mergedPartner;

      for (int otherIndex = index + 1; otherIndex < rawMatches.length; otherIndex++) {
        if (visited.contains(otherIndex)) continue;
        final other = rawMatches[otherIndex];
        if (other.type != current.type || other.orientation == current.orientation) {
          continue;
        }

        if (other.positions.any(current.positions.contains)) {
          mergedPartner = other;
          visited.add(otherIndex);
          break;
        }
      }

      visited.add(index);

      final group = mergedPartner == null ? <_RawMatch>[current] : <_RawMatch>[current, mergedPartner];
      final positions = group.expand((match) => match.positions).toSet();

      final orderedPositions = positions.toList()
        ..sort((a, b) {
          final rowCompare = a.row.compareTo(b.row);
          if (rowCompare != 0) return rowCompare;
          return a.col.compareTo(b.col);
        });

      matches.add(
        Match(
          positions: orderedPositions,
          type: current.type,
          matchType: _resolveMatchType(group, orderedPositions),
        ),
      );
    }

    return matches;
  }

  MatchType _resolveMatchType(List<_RawMatch> group, List<GridPosition> positions) {
    if (group.length == 1) {
      return _lineMatchType(group.first.positions.length);
    }

    final hasHorizontal =
        group.any((match) => match.orientation == _LineOrientation.horizontal);
    final hasVertical =
        group.any((match) => match.orientation == _LineOrientation.vertical);

    if (hasHorizontal && hasVertical) {
      final horizontalPositions = group
          .where((match) => match.orientation == _LineOrientation.horizontal)
          .expand((match) => match.positions)
          .toSet();
      final verticalPositions = group
          .where((match) => match.orientation == _LineOrientation.vertical)
          .expand((match) => match.positions)
          .toSet();

      final intersection = horizontalPositions.intersection(verticalPositions).first;
      final horizontalCols = horizontalPositions.map((pos) => pos.col).toList()
        ..sort();
      final verticalRows = verticalPositions.map((pos) => pos.row).toList()
        ..sort();

      final touchesHorizontalEnd = intersection.col == horizontalCols.first ||
          intersection.col == horizontalCols.last;
      final touchesVerticalEnd =
          intersection.row == verticalRows.first || intersection.row == verticalRows.last;

      return touchesHorizontalEnd && touchesVerticalEnd
          ? MatchType.lShape
          : MatchType.tShape;
    }

    return _lineMatchType(positions.length);
  }

  MatchType _lineMatchType(int length) {
    if (length >= 6) return MatchType.line6Plus;
    if (length == 5) return MatchType.line5;
    if (length == 4) return MatchType.line4;
    return MatchType.normal;
  }

  /// Apply gravity and fill empty spaces
  CascadeResult applyGravity({int comboMultiplier = 1}) {
    final rawMatches = detectMatches();
    final matches = rawMatches
        .map(
          (match) => Match(
            positions: match.positions,
            type: match.type,
            comboMultiplier: comboMultiplier,
            matchType: match.matchType,
          ),
        )
        .toList();

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

      // Fill empty spaces — use anti-match fill to avoid forced auto-chains
      for (int row = writeRow; row >= 0; row--) {
        _grid[row][col] = SushiElement(type: _pickFillType(row, col));
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

  CascadeResult destroyPositions(Set<GridPosition> positions) {
    if (positions.isEmpty) {
      return CascadeResult(
        grid: _grid,
        matches: const [],
        scoreGained: 0,
        hasMoreCascades: false,
      );
    }

    final validPositions = positions.where(_isValidPosition).toSet();
    if (validPositions.isEmpty) {
      return CascadeResult(
        grid: _grid,
        matches: const [],
        scoreGained: 0,
        hasMoreCascades: false,
      );
    }

    for (int col = 0; col < _config.cols; col++) {
      int writeRow = _config.rows - 1;

      for (int row = _config.rows - 1; row >= 0; row--) {
        if (!validPositions.contains(GridPosition(row, col))) {
          _grid[writeRow][col] = _grid[row][col];
          writeRow--;
        }
      }

      for (int row = writeRow; row >= 0; row--) {
        _grid[row][col] = SushiElement(type: _pickFillType(row, col));
      }
    }

    return CascadeResult(
      grid: _grid,
      matches: const [],
      scoreGained: validPositions.length * 25,
      hasMoreCascades: detectMatches().isNotEmpty,
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