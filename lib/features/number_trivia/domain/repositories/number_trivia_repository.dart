import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../enteties/number_trivia.dart';

abstract interface class NumberTriviaRepository {
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number);
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia();
}
