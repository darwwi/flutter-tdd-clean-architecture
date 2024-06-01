import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/enteties/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initial state should be Empty', () {
    expect(bloc.state, equals(Empty()));
  });
  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    setUpAll(() {
      registerFallbackValue(const Params(number: tNumberParsed));
    });
    void setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(const Right(tNumberParsed));

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        build: () {
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      return bloc;
    }, act: (bloc) async {
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    }, verify: (_) {
      verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString));
    });
    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Error] when the input is invalid',
        build: () {
          when(() => mockInputConverter.stringToUnsignedInteger(any()))
              .thenReturn(Left(InvalidInputFailure()));
          when(() => mockGetConcreteNumberTrivia(any()))
              .thenAnswer((_) async => const Right(tNumberTrivia));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        },
        expect: () => [const Error(message: FailureMessage.invalidInput)]);
    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should get data from the concrete use case', build: () {
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      return bloc;
    }, act: (bloc) async {
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    }, verify: (_) {
      verify(() => mockGetConcreteNumberTrivia(
            const Params(number: tNumberParsed),
          ));
    });
    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Loading, Loaded ] when data is gotten successfully',
        build: () {
          setUpMockInputConverterSuccess();
          when(() => mockGetConcreteNumberTrivia(any()))
              .thenAnswer((_) async => const Right(tNumberTrivia));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        },
        expect: () => [
              Loading(),
              const Loaded(trivia: tNumberTrivia),
            ]);
    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Loading, Error] when a proper message for the error when getting data fails',
        build: () {
          setUpMockInputConverterSuccess();
          when(() => mockGetConcreteNumberTrivia(any()))
              .thenAnswer((_) async => Left(CacheFailure()));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        },
        expect: () => [
              Loading(),
              const Error(message: FailureMessage.cache),
            ]);
  });
  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');
    setUpAll(() {
      registerFallbackValue(NoParams());
    });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should get data from the random use case', build: () {
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      return bloc;
    }, act: (bloc) async {
      bloc.add(GetTriviaForRandomNumber());
    }, verify: (_) {
      verify(() => mockGetRandomNumberTrivia(
            NoParams(),
          ));
    });
    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Loading, Loaded ] when data is gotten successfully',
        build: () {
          when(() => mockGetRandomNumberTrivia(any()))
              .thenAnswer((_) async => const Right(tNumberTrivia));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(GetTriviaForRandomNumber());
        },
        expect: () => [
              Loading(),
              const Loaded(trivia: tNumberTrivia),
            ]);
    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Loading, Error] when a proper message for the error when getting data fails',
        build: () {
          when(() => mockGetRandomNumberTrivia(any()))
              .thenAnswer((_) async => Left(CacheFailure()));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(GetTriviaForRandomNumber());
        },
        expect: () => [
              Loading(),
              const Error(message: FailureMessage.cache),
            ]);
  });
}
