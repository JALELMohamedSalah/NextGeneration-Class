import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/model/scan.dart';

/// One page being cropped: four corners to drag, a quarter turn, back to the photo as taken.
class CropCubit extends Cubit<ScanPage> {
  CropCubit(super.page);

  void moveCorner(int index, ScanPoint point) => emit(state.withCorner(index, point));

  void rotate() => emit(state.rotated());

  void reset() => emit(state.reset());
}
