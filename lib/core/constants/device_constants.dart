import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../interfaces/device_interface.dart';
import '../constants/device_constants.dart';

class RealBluetoothDevice implements DeviceInterface {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<List<int>>? _dataSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  QualifiedCharacteristic? _txCharacteristic;
  
  final StreamController<String> _responseController = StreamController<String>.broadcast();
  final StreamController<ConnectionState> _connectionController = StreamController<ConnectionState>.broadcast();
  
  bool _isConnected = false;
  String? _connectedDeviceId;

  @override
  bool get isConnected => _isConnected;

  @override
  Future<bool> connect() async {
    try {
      _connectionController.add(ConnectionState.connecting);
      
      // Buscar dispositivos disponíveis
      final devices = await _scanForDevices();
      if (devices.isEmpty) {
        throw Exception('Nenhum dispositivo BLE encontrado');
      }
      
      // Conectar ao primeiro dispositivo (em produção, deixe o usuário escolher)
      final device = devices.first;
      _connectedDeviceId = device.id;
      
      _connectionSubscription = _ble.connectToDevice(id: device.id).listen(
        (update) {
          switch (update.connectionState) {
            case DeviceConnectionState.connected:
              _isConnected = true;
              _connectionController.add(ConnectionState.connected);
              _discoverServices(device.id);
              break;
            case DeviceConnectionState.connecting:
              _connectionController.add(ConnectionState.connecting);
              break;
            case DeviceConnectionState.disconnected:
              _isConnected = false;
              _connectionController.add(ConnectionState.disconnected);
              break;
            case DeviceConnectionState.disconnecting:
              _isConnected = false;
              break;
          }
        },
        onError: (error) {
          _isConnected = false;
          _connectionController.add(ConnectionState.disconnected);
        },
      );
      
      return true;
    } catch (e) {
      _isConnected = false;
      _connectionController.add(ConnectionState.disconnected);
      return false;
    }
  }

  Future<List<DiscoveredDevice>> _scanForDevices() async {
    final completer = Completer<List<DiscoveredDevice>>();
    final devices = <DiscoveredDevice>[];
    
    final subscription = _ble.scanForDevices(
      withServices: DeviceConstants.supportedServices,
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      devices.add(device);
    }, onDone: () {
      if (!completer.isCompleted) {
        completer.complete(devices);
      }
    });

    // Escanear por 5 segundos
    await Future.delayed(const Duration(seconds: 5));
    await subscription.cancel();
    
    if (!completer.isCompleted) {
      completer.complete(devices);
    }
    
    return completer.future;
  }

  Future<void> _discoverServices(String deviceId) async {
    try {
      final services = await _ble.discoverServices(deviceId);
      
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          // Característica TX (envio)
          if (characteristic.characteristicUuid.toString().toUpperCase() == 
              DeviceConstants.txCharacteristicUuid.toUpperCase()) {
            _txCharacteristic = QualifiedCharacteristic(
              serviceId: service.serviceUuid,
              characteristicId: characteristic.characteristicUuid,
              deviceId: deviceId,
            );
          }
          
          // Característica RX (recebimento)
          if (characteristic.characteristicUuid.toString().toUpperCase() == 
              DeviceConstants.rxCharacteristicUuid.toUpperCase()) {
            _dataSubscription = _ble.subscribeToCharacteristic(
              QualifiedCharacteristic(
                serviceId: service.serviceUuid,
                characteristicId: characteristic.characteristicUuid,
                deviceId: deviceId,
              ),
            ).listen((data) {
              final response = utf8.decode(data);
              _responseController.add(response);
            });
          }
        }
      }
    } catch (e) {
      _responseController.add('Erro ao descobrir serviços: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    await _dataSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _isConnected = false;
    _connectionController.add(ConnectionState.disconnected);
  }

  @override
  Future<void> sendCommand(String command) async {
    if (_txCharacteristic == null || !_isConnected) {
      throw Exception('Dispositivo não conectado ou característica TX não encontrada');
    }
    
    try {
      await _ble.writeCharacteristicWithResponse(
        _txCharacteristic!,
        value: utf8.encode('$command\n'), // Adiciona newline para comandos
      );
    } catch (e) {
      throw Exception('Erro ao enviar comando: $e');
    }
  }

  @override
  Stream<String> get responseStream => _responseController.stream;

  @override
  Stream<ConnectionState> get connectionState => _connectionController.stream;

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _connectionSubscription?.cancel();
    _responseController.close();
    _connectionController.close();
  }
}