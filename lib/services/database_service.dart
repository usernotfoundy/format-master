// ============================================
// FILE: lib/services/database_service.dart
// ============================================
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/lesson.dart';
import '../models/quiz.dart';
import '../models/progress.dart';

// Conditional import for platform checks and path_provider
import 'database_service_stub.dart'
    if (dart.library.io) 'database_service_io.dart' as platform_helper;

class DatabaseService {
  static Database? _database;
  static bool _isInitialized = false;
  
  // In-memory storage for web
  static final Map<String, List<Map<String, dynamic>>> _webStorage = {
    'users': [],
    'lessons': [],
    'quiz_questions': [],
    'progress': [],
  };
  static int _webUserIdCounter = 1;
  static int _webProgressIdCounter = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    await initDatabase();
    return _database!;
  }

  Future<void> initDatabase() async {
    // Prevent re-initialization
    if (_isInitialized) return;

    if (kIsWeb) {
      // For web, use in-memory storage (no actual database)
      await _initWebData();
      _isInitialized = true;
      return;
    }

    // For desktop support
    await platform_helper.initializePlatformDatabase();

    final path = join(await platform_helper.getDatabasePath(), 'text_formatting_app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
    _isInitialized = true;
  }

  Future<void> _initWebData() async {
    // Initialize lessons and quiz questions in memory
    _webStorage['lessons'] = _getDefaultLessons();
    _webStorage['quiz_questions'] = _getDefaultQuizQuestions();
  }

  List<Map<String, dynamic>> _getDefaultLessons() {
    return [
      {'id': 1, 'title': 'Bold Text', 'category': 'Basic Formatting', 'description': 'Learn how to make text bold', 'content': 'Bold text is used to emphasize important words.|||To make text bold, select the text and click the Bold button (B) or press Ctrl+B.|||Bold text stands out and catches the reader\'s attention.|||Try it: Select any text and make it bold!', 'xpReward': 10, 'orderNum': 1},
      {'id': 2, 'title': 'Italic Text', 'category': 'Basic Formatting', 'description': 'Learn how to italicize text', 'content': 'Italic text is slanted and used for emphasis or titles.|||To italicize text, select it and click the Italic button (I) or press Ctrl+I.|||Italics are often used for book titles, foreign words, or subtle emphasis.|||Practice: Make some text italic!', 'xpReward': 10, 'orderNum': 2},
      {'id': 3, 'title': 'Underline Text', 'category': 'Basic Formatting', 'description': 'Learn how to underline text', 'content': 'Underlined text has a line beneath it.|||To underline, select text and click the Underline button (U) or press Ctrl+U.|||Use underlines sparingly - they can be confused with hyperlinks.|||Your turn: Underline some text!', 'xpReward': 10, 'orderNum': 3},
      {'id': 4, 'title': 'Text Alignment', 'category': 'Paragraph Formatting', 'description': 'Learn about left, center, right, and justified alignment', 'content': 'Text alignment controls how text lines up on the page.|||Left alignment: Text starts at the left margin (most common).|||Center alignment: Text is centered between margins (used for titles).|||Right alignment: Text aligns to the right margin.|||Justified: Text spreads evenly from left to right margins.|||Try different alignments to see how they look!', 'xpReward': 15, 'orderNum': 4},
      {'id': 5, 'title': 'Line Spacing', 'category': 'Paragraph Formatting', 'description': 'Control space between lines', 'content': 'Line spacing is the vertical space between lines of text.|||Single spacing: Lines are close together.|||1.5 spacing: Medium spacing for easier reading.|||Double spacing: Maximum spacing, often used for drafts.|||Good spacing makes documents easier to read!|||Experiment with different line spacings.', 'xpReward': 15, 'orderNum': 5},
      {'id': 6, 'title': 'Indentation', 'category': 'Paragraph Formatting', 'description': 'Learn about indenting paragraphs', 'content': 'Indentation moves text away from the margin.|||First line indent: Only the first line is indented (common for paragraphs).|||Hanging indent: All lines except the first are indented (used for bibliographies).|||Left indent: Entire paragraph moves right.|||Right indent: Entire paragraph moves left from right margin.|||Practice creating different indents!', 'xpReward': 15, 'orderNum': 6},
      {'id': 7, 'title': 'Highlighting', 'category': 'Advanced Formatting', 'description': 'Add background color to text', 'content': 'Highlighting adds a colored background to text.|||It helps important information stand out.|||Use bright colors like yellow for highlighting.|||Don\'t overuse highlighting - it loses effectiveness.|||Highlight key terms or important notes!', 'xpReward': 20, 'orderNum': 7},
      {'id': 8, 'title': 'Superscript & Subscript', 'category': 'Advanced Formatting', 'description': 'Raise or lower text', 'content': 'Superscript raises text above the baseline (e.g., x²).|||Subscript lowers text below the baseline (e.g., H₂O).|||Superscripts are used for exponents and footnotes.|||Subscripts are used in chemical formulas and math.|||Try creating: 2⁴ = 16 and H₂O!', 'xpReward': 20, 'orderNum': 8},
      {'id': 9, 'title': 'Strikethrough', 'category': 'Advanced Formatting', 'description': 'Draw a line through text', 'content': 'Strikethrough puts a horizontal line through text.|||It shows that text has been removed or is no longer valid.|||Commonly used in editing and revision.|||To apply: Select text and use the strikethrough button.|||Practice: Mark some text as deleted!', 'xpReward': 20, 'orderNum': 9},
      {'id': 10, 'title': 'Small Caps', 'category': 'Advanced Formatting', 'description': 'Use small capital letters', 'content': 'Small caps make lowercase letters look like smaller capitals.|||EXAMPLE: THIS IS SMALL CAPS.|||Often used for acronyms or stylistic purposes.|||Creates a professional, elegant look.|||Try formatting text in small caps!', 'xpReward': 20, 'orderNum': 10},
    ];
  }

  List<Map<String, dynamic>> _getDefaultQuizQuestions() {
    return [
      {'id': 1, 'lessonId': 1, 'question': 'What keyboard shortcut makes text bold?', 'options': 'Ctrl+B|||Ctrl+I|||Ctrl+U|||Ctrl+H', 'correctAnswer': 0},
      {'id': 2, 'lessonId': 1, 'question': 'Bold text is used to:', 'options': 'Emphasize important words|||Make text smaller|||Delete text|||Change font color', 'correctAnswer': 0},
      {'id': 3, 'lessonId': 1, 'question': 'Which button applies bold formatting?', 'options': 'B|||I|||U|||S', 'correctAnswer': 0},
      {'id': 4, 'lessonId': 2, 'question': 'What shortcut italicizes text?', 'options': 'Ctrl+I|||Ctrl+B|||Ctrl+U|||Ctrl+T', 'correctAnswer': 0},
      {'id': 5, 'lessonId': 2, 'question': 'Italics are often used for:', 'options': 'Book titles|||Email addresses|||Phone numbers|||Dates', 'correctAnswer': 0},
      {'id': 6, 'lessonId': 2, 'question': 'Italic text appears:', 'options': 'Slanted|||Bold|||Underlined|||Colored', 'correctAnswer': 0},
      {'id': 7, 'lessonId': 3, 'question': 'The underline shortcut is:', 'options': 'Ctrl+U|||Ctrl+B|||Ctrl+I|||Ctrl+L', 'correctAnswer': 0},
      {'id': 8, 'lessonId': 3, 'question': 'Underlines can be confused with:', 'options': 'Hyperlinks|||Bold text|||Italic text|||Headers', 'correctAnswer': 0},
      {'id': 9, 'lessonId': 4, 'question': 'Which alignment is most common for body text?', 'options': 'Left|||Center|||Right|||Justified', 'correctAnswer': 0},
      {'id': 10, 'lessonId': 4, 'question': 'Center alignment is best for:', 'options': 'Titles|||Paragraphs|||Lists|||Footnotes', 'correctAnswer': 0},
      {'id': 11, 'lessonId': 4, 'question': 'Justified alignment:', 'options': 'Spreads text evenly|||Centers text|||Right aligns text|||Bolds text', 'correctAnswer': 0},
      {'id': 12, 'lessonId': 5, 'question': 'Double spacing is often used for:', 'options': 'Drafts|||Final copies|||Titles|||Footnotes', 'correctAnswer': 0},
      {'id': 13, 'lessonId': 5, 'question': 'Line spacing controls:', 'options': 'Vertical space between lines|||Horizontal space|||Font size|||Text color', 'correctAnswer': 0},
      {'id': 14, 'lessonId': 6, 'question': 'A hanging indent is used for:', 'options': 'Bibliographies|||Paragraphs|||Titles|||Headers', 'correctAnswer': 0},
      {'id': 15, 'lessonId': 6, 'question': 'First line indent affects:', 'options': 'Only the first line|||All lines|||Last line only|||No lines', 'correctAnswer': 0},
      {'id': 16, 'lessonId': 7, 'question': 'Highlighting adds:', 'options': 'Background color|||Text color|||Border|||Shadow', 'correctAnswer': 0},
      {'id': 17, 'lessonId': 7, 'question': 'The most common highlight color is:', 'options': 'Yellow|||Red|||Blue|||Green', 'correctAnswer': 0},
      {'id': 18, 'lessonId': 8, 'question': 'In H₂O, the 2 is:', 'options': 'Subscript|||Superscript|||Bold|||Italic', 'correctAnswer': 0},
      {'id': 19, 'lessonId': 8, 'question': 'Superscript is used for:', 'options': 'Exponents|||Chemical formulas|||Addresses|||Names', 'correctAnswer': 0},
      {'id': 20, 'lessonId': 9, 'question': 'Strikethrough shows text is:', 'options': 'Removed or invalid|||Important|||New|||Highlighted', 'correctAnswer': 0},
      {'id': 21, 'lessonId': 10, 'question': 'Small caps make lowercase letters look like:', 'options': 'Smaller capitals|||Larger letters|||Bold text|||Italic text', 'correctAnswer': 0},
    ];
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        avatarId TEXT NOT NULL,
        level INTEGER DEFAULT 1,
        xp INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Lessons table
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        content TEXT NOT NULL,
        xpReward INTEGER DEFAULT 10,
        orderNum INTEGER NOT NULL
      )
    ''');

    // Quiz questions table
    await db.execute('''
      CREATE TABLE quiz_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lessonId INTEGER NOT NULL,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        correctAnswer INTEGER NOT NULL,
        FOREIGN KEY (lessonId) REFERENCES lessons (id)
      )
    ''');

    // Progress table
    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        lessonId INTEGER NOT NULL,
        completed INTEGER DEFAULT 0,
        quizScore INTEGER,
        completedAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (lessonId) REFERENCES lessons (id)
      )
    ''');

    // Insert default lessons
    await _insertDefaultLessons(db);
  }

  Future<void> _insertDefaultLessons(Database db) async {
    final lessons = [
      {
        'id': 1,
        'title': 'Bold Text',
        'category': 'Basic Formatting',
        'description': 'Learn how to make text bold',
        'content':
            'Bold text is used to emphasize important words.|||To make text bold, select the text and click the Bold button (B) or press Ctrl+B.|||Bold text stands out and catches the reader\'s attention.|||Try it: Select any text and make it bold!',
        'xpReward': 10,
        'orderNum': 1,
      },
      {
        'id': 2,
        'title': 'Italic Text',
        'category': 'Basic Formatting',
        'description': 'Learn how to italicize text',
        'content':
            'Italic text is slanted and used for emphasis or titles.|||To italicize text, select it and click the Italic button (I) or press Ctrl+I.|||Italics are often used for book titles, foreign words, or subtle emphasis.|||Practice: Make some text italic!',
        'xpReward': 10,
        'orderNum': 2,
      },
      {
        'id': 3,
        'title': 'Underline Text',
        'category': 'Basic Formatting',
        'description': 'Learn how to underline text',
        'content':
            'Underlined text has a line beneath it.|||To underline, select text and click the Underline button (U) or press Ctrl+U.|||Use underlines sparingly - they can be confused with hyperlinks.|||Your turn: Underline some text!',
        'xpReward': 10,
        'orderNum': 3,
      },
      {
        'id': 4,
        'title': 'Text Alignment',
        'category': 'Paragraph Formatting',
        'description':
            'Learn about left, center, right, and justified alignment',
        'content':
            'Text alignment controls how text lines up on the page.|||Left alignment: Text starts at the left margin (most common).|||Center alignment: Text is centered between margins (used for titles).|||Right alignment: Text aligns to the right margin.|||Justified: Text spreads evenly from left to right margins.|||Try different alignments to see how they look!',
        'xpReward': 15,
        'orderNum': 4,
      },
      {
        'id': 5,
        'title': 'Line Spacing',
        'category': 'Paragraph Formatting',
        'description': 'Control space between lines',
        'content':
            'Line spacing is the vertical space between lines of text.|||Single spacing: Lines are close together.|||1.5 spacing: Medium spacing for easier reading.|||Double spacing: Maximum spacing, often used for drafts.|||Good spacing makes documents easier to read!|||Experiment with different line spacings.',
        'xpReward': 15,
        'orderNum': 5,
      },
      {
        'id': 6,
        'title': 'Indentation',
        'category': 'Paragraph Formatting',
        'description': 'Learn about indenting paragraphs',
        'content':
            'Indentation moves text away from the margin.|||First line indent: Only the first line is indented (common for paragraphs).|||Hanging indent: All lines except the first are indented (used for bibliographies).|||Left indent: Entire paragraph moves right.|||Right indent: Entire paragraph moves left from right margin.|||Practice creating different indents!',
        'xpReward': 15,
        'orderNum': 6,
      },
      {
        'id': 7,
        'title': 'Highlighting',
        'category': 'Advanced Formatting',
        'description': 'Add background color to text',
        'content':
            'Highlighting adds a colored background to text.|||It helps important information stand out.|||Use bright colors like yellow for highlighting.|||Don\'t overuse highlighting - it loses effectiveness.|||Highlight key terms or important notes!',
        'xpReward': 20,
        'orderNum': 7,
      },
      {
        'id': 8,
        'title': 'Superscript & Subscript',
        'category': 'Advanced Formatting',
        'description': 'Raise or lower text',
        'content':
            'Superscript raises text above the baseline (e.g., x²).|||Subscript lowers text below the baseline (e.g., H₂O).|||Superscripts are used for exponents and footnotes.|||Subscripts are used in chemical formulas and math.|||Try creating: 2⁴ = 16 and H₂O!',
        'xpReward': 20,
        'orderNum': 8,
      },
      {
        'id': 9,
        'title': 'Strikethrough',
        'category': 'Advanced Formatting',
        'description': 'Draw a line through text',
        'content':
            'Strikethrough puts a horizontal line through text.|||It shows that text has been removed or is no longer valid.|||Commonly used in editing and revision.|||To apply: Select text and use the strikethrough button.|||Practice: Mark some text as deleted!',
        'xpReward': 20,
        'orderNum': 9,
      },
      {
        'id': 10,
        'title': 'Small Caps',
        'category': 'Advanced Formatting',
        'description': 'Use small capital letters',
        'content':
            'Small caps make lowercase letters look like smaller capitals.|||EXAMPLE: THIS IS SMALL CAPS.|||Often used for acronyms or stylistic purposes.|||Creates a professional, elegant look.|||Try formatting text in small caps!',
        'xpReward': 20,
        'orderNum': 10,
      },
    ];

    for (var lesson in lessons) {
      await db.insert('lessons', lesson);
    }

    // Insert quiz questions for each lesson
    await _insertQuizQuestions(db);
  }

  Future<void> _insertQuizQuestions(Database db) async {
    final quizQuestions = [
      // Lesson 1: Bold
      {
        'lessonId': 1,
        'question': 'What keyboard shortcut makes text bold?',
        'options': 'Ctrl+B|||Ctrl+I|||Ctrl+U|||Ctrl+H',
        'correctAnswer': 0
      },
      {
        'lessonId': 1,
        'question': 'Bold text is used to:',
        'options':
            'Emphasize important words|||Make text smaller|||Delete text|||Change font color',
        'correctAnswer': 0
      },
      {
        'lessonId': 1,
        'question': 'Which button applies bold formatting?',
        'options': 'B|||I|||U|||S',
        'correctAnswer': 0
      },

      // Lesson 2: Italic
      {
        'lessonId': 2,
        'question': 'What shortcut italicizes text?',
        'options': 'Ctrl+I|||Ctrl+B|||Ctrl+U|||Ctrl+T',
        'correctAnswer': 0
      },
      {
        'lessonId': 2,
        'question': 'Italics are often used for:',
        'options': 'Book titles|||Email addresses|||Phone numbers|||Dates',
        'correctAnswer': 0
      },
      {
        'lessonId': 2,
        'question': 'Italic text appears:',
        'options': 'Slanted|||Bold|||Underlined|||Colored',
        'correctAnswer': 0
      },

      // Lesson 3: Underline
      {
        'lessonId': 3,
        'question': 'The underline shortcut is:',
        'options': 'Ctrl+U|||Ctrl+B|||Ctrl+I|||Ctrl+L',
        'correctAnswer': 0
      },
      {
        'lessonId': 3,
        'question': 'Underlines can be confused with:',
        'options': 'Hyperlinks|||Bold text|||Italic text|||Headers',
        'correctAnswer': 0
      },

      // Lesson 4: Alignment
      {
        'lessonId': 4,
        'question': 'Which alignment is most common for body text?',
        'options': 'Left|||Center|||Right|||Justified',
        'correctAnswer': 0
      },
      {
        'lessonId': 4,
        'question': 'Center alignment is best for:',
        'options': 'Titles|||Paragraphs|||Lists|||Footnotes',
        'correctAnswer': 0
      },
      {
        'lessonId': 4,
        'question': 'Justified alignment:',
        'options':
            'Spreads text evenly|||Centers text|||Right aligns text|||Bolds text',
        'correctAnswer': 0
      },

      // Lesson 5: Line Spacing
      {
        'lessonId': 5,
        'question': 'Double spacing is often used for:',
        'options': 'Drafts|||Final copies|||Titles|||Footnotes',
        'correctAnswer': 0
      },
      {
        'lessonId': 5,
        'question': 'Line spacing controls:',
        'options':
            'Vertical space between lines|||Horizontal space|||Font size|||Text color',
        'correctAnswer': 0
      },

      // Lesson 6: Indentation
      {
        'lessonId': 6,
        'question': 'A hanging indent is used for:',
        'options': 'Bibliographies|||Paragraphs|||Titles|||Headers',
        'correctAnswer': 0
      },
      {
        'lessonId': 6,
        'question': 'First line indent affects:',
        'options':
            'Only the first line|||All lines|||Last line only|||No lines',
        'correctAnswer': 0
      },

      // Lesson 7: Highlighting
      {
        'lessonId': 7,
        'question': 'Highlighting adds:',
        'options': 'Background color|||Text color|||Border|||Shadow',
        'correctAnswer': 0
      },
      {
        'lessonId': 7,
        'question': 'The most common highlight color is:',
        'options': 'Yellow|||Red|||Blue|||Green',
        'correctAnswer': 0
      },

      // Lesson 8: Super/Subscript
      {
        'lessonId': 8,
        'question': 'In H₂O, the 2 is:',
        'options': 'Subscript|||Superscript|||Bold|||Italic',
        'correctAnswer': 0
      },
      {
        'lessonId': 8,
        'question': 'Superscript is used for:',
        'options': 'Exponents|||Chemical formulas|||Addresses|||Names',
        'correctAnswer': 0
      },

      // Lesson 9: Strikethrough
      {
        'lessonId': 9,
        'question': 'Strikethrough shows text is:',
        'options': 'Removed or invalid|||Important|||New|||Highlighted',
        'correctAnswer': 0
      },

      // Lesson 10: Small Caps
      {
        'lessonId': 10,
        'question': 'Small caps make lowercase letters look like:',
        'options':
            'Smaller capitals|||Larger letters|||Bold text|||Italic text',
        'correctAnswer': 0
      },
    ];

    for (var question in quizQuestions) {
      await db.insert('quiz_questions', question);
    }
  }

  // User CRUD operations
  Future<int> createUser(User user) async {
    if (kIsWeb) {
      final id = _webUserIdCounter++;
      final userMap = user.toMap();
      userMap['id'] = id;
      _webStorage['users']!.add(userMap);
      return id;
    }
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(int id) async {
    if (kIsWeb) {
      final users = _webStorage['users']!;
      final userMap = users.where((u) => u['id'] == id).firstOrNull;
      if (userMap == null) return null;
      return User.fromMap(userMap);
    }
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<List<User>> getAllUsers() async {
    if (kIsWeb) {
      final users = _webStorage['users']!;
      users.sort((a, b) => (b['createdAt'] as String).compareTo(a['createdAt'] as String));
      return users.map((map) => User.fromMap(map)).toList();
    }
    final db = await database;
    final maps = await db.query('users', orderBy: 'createdAt DESC');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<int> updateUser(User user) async {
    if (kIsWeb) {
      final users = _webStorage['users']!;
      final index = users.indexWhere((u) => u['id'] == user.id);
      if (index != -1) {
        users[index] = user.toMap();
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db
        .update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Lesson operations
  Future<List<Lesson>> getAllLessons() async {
    if (kIsWeb) {
      final lessons = List<Map<String, dynamic>>.from(_webStorage['lessons']!);
      lessons.sort((a, b) => (a['orderNum'] as int).compareTo(b['orderNum'] as int));
      return lessons.map((map) => Lesson.fromMap(map)).toList();
    }
    final db = await database;
    final maps = await db.query('lessons', orderBy: 'orderNum ASC');
    return maps.map((map) => Lesson.fromMap(map)).toList();
  }

  Future<Lesson?> getLesson(int id) async {
    if (kIsWeb) {
      final lessons = _webStorage['lessons']!;
      final lessonMap = lessons.where((l) => l['id'] == id).firstOrNull;
      if (lessonMap == null) return null;
      return Lesson.fromMap(lessonMap);
    }
    final db = await database;
    final maps = await db.query('lessons', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Lesson.fromMap(maps.first);
  }

  // Quiz operations
  Future<List<QuizQuestion>> getQuizQuestions(int lessonId) async {
    if (kIsWeb) {
      final questions = _webStorage['quiz_questions']!;
      return questions
          .where((q) => q['lessonId'] == lessonId)
          .map((map) => QuizQuestion.fromMap(map))
          .toList();
    }
    final db = await database;
    final maps = await db
        .query('quiz_questions', where: 'lessonId = ?', whereArgs: [lessonId]);
    return maps.map((map) => QuizQuestion.fromMap(map)).toList();
  }

  // Progress operations
  Future<int> saveProgress(Progress progress) async {
    if (kIsWeb) {
      final progressList = _webStorage['progress']!;
      final existingIndex = progressList.indexWhere(
        (p) => p['userId'] == progress.userId && p['lessonId'] == progress.lessonId,
      );
      
      if (existingIndex == -1) {
        final id = _webProgressIdCounter++;
        final progressMap = progress.toMap();
        progressMap['id'] = id;
        progressList.add(progressMap);
        return id;
      } else {
        progressList[existingIndex] = progress.toMap();
        progressList[existingIndex]['id'] = existingIndex + 1;
        return existingIndex + 1;
      }
    }
    final db = await database;
    final existing = await db.query(
      'progress',
      where: 'userId = ? AND lessonId = ?',
      whereArgs: [progress.userId, progress.lessonId],
    );

    if (existing.isEmpty) {
      return await db.insert('progress', progress.toMap());
    } else {
      return await db.update(
        'progress',
        progress.toMap(),
        where: 'userId = ? AND lessonId = ?',
        whereArgs: [progress.userId, progress.lessonId],
      );
    }
  }

  Future<List<Progress>> getUserProgress(int userId) async {
    if (kIsWeb) {
      final progressList = _webStorage['progress']!;
      return progressList
          .where((p) => p['userId'] == userId)
          .map((map) => Progress.fromMap(map))
          .toList();
    }
    final db = await database;
    final maps =
        await db.query('progress', where: 'userId = ?', whereArgs: [userId]);
    return maps.map((map) => Progress.fromMap(map)).toList();
  }

  Future<Progress?> getLessonProgress(int userId, int lessonId) async {
    if (kIsWeb) {
      final progressList = _webStorage['progress']!;
      final progressMap = progressList
          .where((p) => p['userId'] == userId && p['lessonId'] == lessonId)
          .firstOrNull;
      if (progressMap == null) return null;
      return Progress.fromMap(progressMap);
    }
    final db = await database;
    final maps = await db.query(
      'progress',
      where: 'userId = ? AND lessonId = ?',
      whereArgs: [userId, lessonId],
    );
    if (maps.isEmpty) return null;
    return Progress.fromMap(maps.first);
  }

  // Reset all progress for a user
  Future<void> resetUserProgress(int userId) async {
    if (kIsWeb) {
      _webStorage['progress']!.removeWhere((p) => p['userId'] == userId);
      return;
    }
    final db = await database;
    await db.delete('progress', where: 'userId = ?', whereArgs: [userId]);
  }

  // Delete user and their progress
  Future<void> deleteUser(int userId) async {
    if (kIsWeb) {
      _webStorage['users']!.removeWhere((u) => u['id'] == userId);
      _webStorage['progress']!.removeWhere((p) => p['userId'] == userId);
      return;
    }
    final db = await database;
    await db.delete('progress', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
}
