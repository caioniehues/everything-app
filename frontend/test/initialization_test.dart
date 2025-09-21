import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Flutter Project Initialization', () {
    test('should have all required dependencies in pubspec.yaml', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue,
          reason: 'pubspec.yaml must exist');

      final pubspecContent = pubspecFile.readAsStringSync();
      final pubspec = loadYaml(pubspecContent) as Map;
      final dependencies = pubspec['dependencies'] as Map;

      // Core dependencies that must be present
      expect(dependencies.containsKey('flutter_riverpod'), isTrue,
          reason: 'flutter_riverpod is required for state management');
      expect(dependencies.containsKey('go_router'), isTrue,
          reason: 'go_router is required for navigation');
      expect(dependencies.containsKey('dio'), isTrue,
          reason: 'dio is required for HTTP requests');
      expect(dependencies.containsKey('freezed_annotation'), isTrue,
          reason: 'freezed_annotation is required for data classes');
      expect(dependencies.containsKey('json_annotation'), isTrue,
          reason: 'json_annotation is required for JSON serialization');
      expect(dependencies.containsKey('flutter_secure_storage'), isTrue,
          reason: 'flutter_secure_storage is required for secure token storage');
      expect(dependencies.containsKey('hive_flutter'), isTrue,
          reason: 'hive_flutter is required for local caching');
      expect(dependencies.containsKey('intl'), isTrue,
          reason: 'intl is required for internationalization and formatting');
      expect(dependencies.containsKey('flutter_dotenv'), isTrue,
          reason: 'flutter_dotenv is required for environment configuration');
      expect(dependencies.containsKey('riverpod_annotation'), isTrue,
          reason: 'riverpod_annotation is required for code generation');
    });

    test('should have all required dev dependencies', () {
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = pubspecFile.readAsStringSync();
      final pubspec = loadYaml(pubspecContent) as Map;
      final devDependencies = pubspec['dev_dependencies'] as Map;

      expect(devDependencies.containsKey('build_runner'), isTrue,
          reason: 'build_runner is required for code generation');
      expect(devDependencies.containsKey('freezed'), isTrue,
          reason: 'freezed is required for immutable data classes');
      expect(devDependencies.containsKey('json_serializable'), isTrue,
          reason: 'json_serializable is required for JSON code generation');
      expect(devDependencies.containsKey('flutter_test'), isTrue,
          reason: 'flutter_test is required for testing');
      expect(devDependencies.containsKey('flutter_lints'), isTrue,
          reason: 'flutter_lints is required for linting');
      expect(devDependencies.containsKey('mockito'), isTrue,
          reason: 'mockito is required for mocking in tests');
      expect(devDependencies.containsKey('riverpod_generator'), isTrue,
          reason: 'riverpod_generator is required for Riverpod code generation');
      expect(devDependencies.containsKey('riverpod_lint'), isTrue,
          reason: 'riverpod_lint provides linting for Riverpod');
    });

    test('should have strict analysis options configured', () {
      final analysisFile = File('analysis_options.yaml');
      expect(analysisFile.existsSync(), isTrue,
          reason: 'analysis_options.yaml must exist');

      final analysisContent = analysisFile.readAsStringSync();
      final analysis = loadYaml(analysisContent) as Map;

      expect(analysis.containsKey('analyzer'), isTrue,
          reason: 'analyzer section must be configured');
      expect(analysis.containsKey('linter'), isTrue,
          reason: 'linter rules must be configured');

      final analyzer = analysis['analyzer'] as Map?;
      if (analyzer != null) {
        expect(analyzer['language']?['strict-casts'], isTrue,
            reason: 'strict-casts should be enabled');
        expect(analyzer['language']?['strict-inference'], isTrue,
            reason: 'strict-inference should be enabled');
        expect(analyzer['language']?['strict-raw-types'], isTrue,
            reason: 'strict-raw-types should be enabled');
      }
    });

    test('should have environment configuration files', () {
      final envExampleFile = File('.env.example');
      final envFile = File('.env');
      final gitignoreFile = File('.gitignore');

      expect(envExampleFile.existsSync(), isTrue,
          reason: '.env.example must exist as template');
      expect(envFile.existsSync(), isTrue,
          reason: '.env must exist for local configuration');

      // Check that .env is in gitignore
      final gitignoreContent = gitignoreFile.readAsStringSync();
      expect(gitignoreContent.contains('.env\n'), isTrue,
          reason: '.env must be in .gitignore');
      expect(gitignoreContent.contains('!.env.example'), isTrue,
          reason: '.env.example should be explicitly NOT ignored with !.env.example');

      // Check required environment variables in .env.example
      final envExampleContent = envExampleFile.readAsStringSync();
      expect(envExampleContent.contains('API_BASE_URL'), isTrue,
          reason: 'API_BASE_URL must be defined in .env.example');
      expect(envExampleContent.contains('ENVIRONMENT'), isTrue,
          reason: 'ENVIRONMENT must be defined in .env.example');
    });

    test('should have proper project description', () {
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = pubspecFile.readAsStringSync();
      final pubspec = loadYaml(pubspecContent) as Map;

      expect(pubspec['name'], equals('frontend'),
          reason: 'Project name should be "frontend"');
      expect(pubspec['description'], isNot(contains('A new Flutter project')),
          reason: 'Description should be updated from default');
      expect(pubspec['version'], isNotNull,
          reason: 'Version must be specified');
    });

    test('should have README with setup instructions', () {
      final readmeFile = File('README.md');
      expect(readmeFile.existsSync(), isTrue,
          reason: 'README.md must exist');

      final readmeContent = readmeFile.readAsStringSync();
      expect(readmeContent.contains('## Installation'), isTrue,
          reason: 'README must have Installation section');
      expect(readmeContent.contains('## Environment Setup'), isTrue,
          reason: 'README must have Environment Setup section');
      expect(readmeContent.contains('## Running the Application'), isTrue,
          reason: 'README must have Running section');
      expect(readmeContent.contains('flutter pub get'), isTrue,
          reason: 'README must include flutter pub get command');
    });

    test('should have correct Dart SDK constraints', () {
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = pubspecFile.readAsStringSync();
      final pubspec = loadYaml(pubspecContent) as Map;
      final environment = pubspec['environment'] as Map;

      final sdkConstraint = environment['sdk'] as String;
      expect(sdkConstraint.contains('3.9.2'), isTrue,
          reason: 'SDK constraint should specify Dart 3.9.2 compatibility');
    });
  });
}