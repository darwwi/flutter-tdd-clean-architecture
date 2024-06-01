import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:number_trivia/features/number_trivia/domain/enteties/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  mockNumberTriviaRepository = MockNumberTriviaRepository();
  usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);

  const tNumber = 1;
  const tNubmerTrivia = NumberTrivia(number: 1, text: 'test');

  test(
    'should get trivia for the number from the repository',
    () async {
      when(() => mockNumberTriviaRepository.getConcreteNumberTrivia(any()))
          .thenAnswer((_) async => const Right(tNubmerTrivia));
      final result = await usecase(const Params(number: tNumber));

      expect(result, const Right(tNubmerTrivia));

      verify(() => mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber));

      verifyNoMoreInteractions(mockNumberTriviaRepository);
    },
  );
}
