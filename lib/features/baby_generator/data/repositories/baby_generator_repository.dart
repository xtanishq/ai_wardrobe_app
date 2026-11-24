import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../models/baby_config_model.dart';

class BabyGeneratorRepository {
  Future<Either<String, BabyConfigModel>> fetchBabyConfig() async {
    return Right(BabyConfigModel(genders: const [], skins: const []));
  }

  Future<Either<String, String>> generateBaby({
    required File image1,
    required File image2,
    required String gender,
    required String skin,
  }) async {
    return const Left('Baby Generator is temporarily unavailable.');
  }
}
