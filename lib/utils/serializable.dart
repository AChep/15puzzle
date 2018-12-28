import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Serializable {
  void serialize(SerializeOutput output);
}

abstract class DeserializableHelper<T> {
  const DeserializableHelper();

  T deserialize(SerializeInput input);
}

abstract class SerializeOutput {
  void writeInt(int value);

  void writeString(String value);

  void writeSerializable(Serializable value);
}

abstract class SerializeInput {
  int readInt();

  String readString();

  T readDeserializable<T>(DeserializableHelper<T> helper);
}

const _DIVIDER = "_";

class SharedPrefSerializeOutput extends SerializeOutput {
  final String key;

  final SharedPreferences prefs;

  int counter = 0;

  SharedPrefSerializeOutput({@required this.key, this.prefs});

  @override
  void writeInt(int value) {
    write((prefs, key) {
      prefs.setInt(key, value);
    });
  }

  @override
  void writeString(String value) {
    write((prefs, key) {
      prefs.setString(key, value);
    });
  }

  @override
  void writeSerializable(Serializable value) {
    write((prefs, key) {
      final worker = SharedPrefSerializeOutput(
        key: key + _DIVIDER,
        prefs: prefs,
      );

      value.serialize(worker);
    });
  }

  void write(Function(SharedPreferences, String) block) {
    final key = this.key + counter.toString();
    counter++;

    block(prefs, key);
  }
}

class SharedPrefSerializeInput extends SerializeInput {
  final String key;

  final SharedPreferences prefs;

  int counter = 0;

  SharedPrefSerializeInput({@required this.key, this.prefs});

  @override
  int readInt() => read((prefs, key) => prefs.getInt(key));

  @override
  String readString() => read((prefs, key) => prefs.getString(key));

  @override
  T readDeserializable<T>(DeserializableHelper<T> helper) {
    return read((prefs, key) {
      final worker = SharedPrefSerializeInput(
        key: key + _DIVIDER,
        prefs: prefs,
      );

      return helper.deserialize(worker);
    });
  }

  T read<T>(T Function(SharedPreferences, String) block) {
    final key = this.key + counter.toString();
    counter++;

    return block(prefs, key);
  }
}
