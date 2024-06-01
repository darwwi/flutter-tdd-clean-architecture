import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/enteties/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

abstract class FailureMessage {
  static const String server = 'Server Failure';
  static const String cache = 'Cache Failure';
  static const String invalidInput =
      'Invalid Input - The number must be a positive integer or zero.';
  static const String unexpectedError = 'Unexpected Error';
}

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc(
      {required GetConcreteNumberTrivia concrete,
      required GetRandomNumberTrivia random,
      required this.inputConverter})
      : getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(Empty()) {
    on<GetTriviaForConcreteNumber>(_onConcrete);
    on<GetTriviaForRandomNumber>(_onRandom);
  }

  Future<void> _onConcrete(
      GetTriviaForConcreteNumber event, Emitter<NumberTriviaState> emit) async {
    final inputEather =
        inputConverter.stringToUnsignedInteger(event.numberString);
    await inputEather.fold(
        (failure) async =>
            emit(const Error(message: FailureMessage.invalidInput)),
        (integer) async {
      emit(Loading());

      final failureOrTrivia =
          await getConcreteNumberTrivia(Params(number: integer));

      _eitherLoadedOrErrorState(failureOrTrivia, emit);
    });
  }

  Future<void> _onRandom(
      GetTriviaForRandomNumber event, Emitter<NumberTriviaState> emit) async {
    emit(Loading());
    final failureOrTrivia = await getRandomNumberTrivia(NoParams());
    _eitherLoadedOrErrorState(failureOrTrivia, emit);
  }

  void _eitherLoadedOrErrorState(Either<Failure, NumberTrivia> failureOrTrivia,
      Emitter<NumberTriviaState> emit) {
    failureOrTrivia.fold(
        (failure) => emit(Error(message: _mapFailureToMessage(failure))),
        (trivia) => emit(Loaded(trivia: trivia)));
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure.runtimeType) {
      const (ServerFailure) => FailureMessage.server,
      const (CacheFailure) => FailureMessage.cache,
      (_) => FailureMessage.unexpectedError
    };
  }
}
