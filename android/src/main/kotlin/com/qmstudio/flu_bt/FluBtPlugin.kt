package com.qmstudio.flu_bt

import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothAdapter.EXTRA_CONNECTION_STATE
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothDevice.DEVICE_TYPE_DUAL
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.bluetooth.le.ScanSettings.SCAN_MODE_LOW_LATENCY
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.UUID


/** FluBtPlugin */
@SuppressLint("MissingPermission")
class FluBtPlugin: FlutterPlugin, MethodCallHandler, ActivityAware , ScanCallback(){
  companion object{
    const val TAG = "FluBtPlugin"
  }
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var  bluetoothManager:BluetoothManager
  private lateinit var bluetoothAdapter: BluetoothAdapter
  private lateinit var appContext: Context
  private lateinit var activity: Activity

  private val mBroadcastReceiver:BroadcastReceiver = object :BroadcastReceiver(){
    override fun onReceive(context: Context?, intent: Intent?) {
      if(intent != null){
        when (intent.action){
          BluetoothDevice.ACTION_BOND_STATE_CHANGED->{
            val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
            val bondState =
              intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR)
            Log.e(TAG, "onReceive: $bondState")
//            when (bondState) {
//              BluetoothDevice.BOND_BONDED ->
//                connectDevice(device?.address ?:"")
//              BluetoothDevice.BOND_BONDING -> {
//                Log.e(TAG, "onReceive: ${device?.address}")
//                connectDevice(device?.address ?:"")
//              }
//              BluetoothDevice.BOND_NONE -> {
//              }
//            }
          }
          BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED->{
            val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
            if(device != null){
              val state =
                intent.getIntExtra(EXTRA_CONNECTION_STATE, BluetoothProfile.STATE_DISCONNECTED)
              invokeMethod("peripheralStateChanged", mapOf("uuid" to device.address, "state" to state))
            }
          }
          BluetoothAdapter.ACTION_STATE_CHANGED->{
            val state =  intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.STATE_TURNING_OFF)
            invokeMethod("invokeMethod",state)
          }
        }
      }
    }
  }
  private fun registerReceiver(){
    val filter = IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
    filter.addAction(BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED)
    filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
    appContext.registerReceiver(mBroadcastReceiver,filter)
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flu_bt")
    channel.setMethodCallHandler(this)
    appContext = flutterPluginBinding.applicationContext
    registerReceiver()
    bluetoothManager =
      appContext.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    bluetoothAdapter = bluetoothManager.adapter

  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onDetachedFromActivity() {
  }



  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when(call.method){
      "getPlatformVersion"->result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "getCentralState"->result.success(if(bluetoothAdapter.isEnabled) Define.CENTRAL_STATE_POWER_ON else Define.CENTRAL_STATE_POWER_OFF)
      "makeEnable"->result.success(bluetoothAdapter.enable())
      "gotoSettings"-> activity.startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS))
      "startScan"->{
        if(isScanning){
          return
        }
        isScanning = true
        val scanSettings = ScanSettings.Builder()
          .setScanMode(SCAN_MODE_LOW_LATENCY)
          .build()
        bluetoothAdapter.bluetoothLeScanner.startScan(null,scanSettings,this)
      }
      "stopScan"->{
        if(!isScanning){
          return
        }
        isScanning = false
        bluetoothAdapter.bluetoothLeScanner.stopScan(this)
      }
      "connect"->{
        val arguments = call.arguments as Map<*, *>
        val uuid = arguments["uuid"] ?: ""
        val device = peripherals[uuid]
        if(device == null){
          result.success(mapOf("status" to false,"code" to 1,"msg" to "找不到外设"))
          return
        }
        if( false&&device.type == DEVICE_TYPE_DUAL&&device.bondState == BluetoothDevice.BOND_NONE){
          device.createBond()
        }else{
          connectDevice(device.address)
//          device.connectGatt(appContext,true,gattCallback, BluetoothDevice.TRANSPORT_LE)
        }
      }
      "disconnect"->{
        val arguments = call.arguments as Map<*, *>
        val uuid = arguments["uuid"] ?: ""
        val gatt = bluetoothGatts[uuid]
        if(gatt == null){
          result.success(mapOf("status" to false,"code" to 1,"msg" to "找不到外设"))
          return
        }
        gatt.disconnect()
      }
      "write"->{
        Log.e(TAG, "onMethodCall: 写入数据", )
        val arguments = call.arguments as Map<*, *>
        val uuid = arguments["uuid"] ?: ""
        val data = arguments["data"] as ByteArray
        val characteristicUUID:String = (arguments["characteristicUUID"] ?: "") as String
        val gatt = bluetoothGatts[uuid]
        if(gatt == null){
          result.success(mapOf("status" to false,"code" to 1,"msg" to "找不到外设"))
          return
        }
        val list = mutableListOf<BluetoothGattCharacteristic>()
        list.addAll(writeWithoutResponseCharacteristics[uuid] ?: listOf())
        list.addAll(writeCharacteristics[uuid] ?: listOf())
        if (list.isEmpty()){
          result.success(mapOf("status" to false,"code" to 3,"msg" to "找不到写特征"))
          return
        }
        var characteristic = list.first()
        if(!characteristicUUID.isNullOrEmpty()){
          for (char in list){
            if(char.uuid.toString() == characteristicUUID){
              characteristic = char
              break
            }
          }
        }
        characteristic.value = data
        gatt.writeCharacteristic(characteristic)
      }
      else->result.notImplemented()
    }
  }
  fun connectDevice(uuid:String){
    val device = peripherals[uuid]


    val gattServer = device?.connectGatt(appContext,false,gattCallback, BluetoothDevice.TRANSPORT_LE)
    gattServer?.requestConnectionPriority(BluetoothGatt.CONNECTION_PRIORITY_HIGH)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      gattServer?.setPreferredPhy(
        BluetoothDevice.PHY_LE_2M,
        BluetoothDevice.PHY_LE_2M,
        BluetoothDevice.PHY_OPTION_NO_PREFERRED
      )
    }
  }

  private fun invokeMethod(method:String, arguments:Any?){
    Handler(Looper.getMainLooper()).post {
      channel.invokeMethod(method,arguments)
    }
  }

  private var isScanning = false
  private val peripherals = mutableMapOf<String,BluetoothDevice>()
  private val bluetoothGatts = mutableMapOf<String,BluetoothGatt>()
  override fun onScanResult(callbackType: Int, result: ScanResult?) {
    if(result != null){
      val res = mapOf(
        "name" to (result.device?.name ?: ""),
        "rssi" to (result.rssi),
        "uuid" to result.device.address
      )
      peripherals[result.device.address] = result.device
      invokeMethod("didDiscoverPeripheral", listOf(res))
    }
  }

  override fun onBatchScanResults(results: MutableList<ScanResult>?) {
    if(!results.isNullOrEmpty()){
      val res = mutableListOf<Map<*,*>>()
      results.forEach {
        res.add(mapOf(
          "name" to (it.device?.name ?: ""),
          "rssi" to (it.rssi),
          "uuid" to it.device.address
        ))
        peripherals[it.device.address] = it.device
      }
//       val res =  results.map { mapOf(
//        "name" to (it.device?.name ?: ""),
//        "rssi" to (it.rssi),
//        "uuid" to it.device.address
//      ) }
      invokeMethod("didDiscoverPeripheral", listOf(res))
    }
  }
  override fun onScanFailed(errorCode: Int) {
    isScanning = false
    Log.e(TAG, "onScanFailed: $errorCode")
  }
  private val writeCharacteristics:MutableMap<String,List<BluetoothGattCharacteristic>> = mutableMapOf()
  private val writeWithoutResponseCharacteristics:MutableMap<String,List<BluetoothGattCharacteristic>> = mutableMapOf()
  private val peripheralStateInfos = mutableMapOf<String,Int>()
  private val gattCallback: BluetoothGattCallback = object :BluetoothGattCallback(){
    override fun onConnectionStateChange(gatt: BluetoothGatt?, status: Int, newState: Int) {
      Log.e(TAG, "onConnectionStateChange: $status to $newState")
      if(gatt != null){
        val adr = gatt.device.address
        peripheralStateInfos[adr] = newState
        if(newState == BluetoothProfile.STATE_CONNECTED){
          bluetoothGatts[adr] = gatt
          gatt.discoverServices()
        }
        if(newState == BluetoothProfile.STATE_DISCONNECTED){
          bluetoothGatts.remove(adr)
          gatt?.close()
        }
        invokeMethod("peripheralStateChanged", mapOf("uuid" to adr, "state" to newState))
      }

      super.onConnectionStateChange(gatt, status, newState)
    }
    override fun onServicesDiscovered(gatt: BluetoothGatt?, status: Int) {
      super.onServicesDiscovered(gatt, status)
      if(gatt != null){
        val uuid = gatt.device.address
        val writeCharacteristicList = mutableListOf<BluetoothGattCharacteristic>()
        val writeWithoutResponseCharacteristicsList = mutableListOf<BluetoothGattCharacteristic>()
//        gatt.requestMtu(512)
        gatt.services.forEach {
          for (characteristic in it.characteristics){
            if(!characteristic.uuid.toString().endsWith("0000-1000-8000-00805f9b34fb")){
              continue
            }
            if(characteristic.properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY == BluetoothGattCharacteristic.PROPERTY_NOTIFY ){
              val enable = gatt.setCharacteristicNotification(characteristic,true)
              if(enable){
                val cccDescriptor: BluetoothGattDescriptor? = characteristic.getDescriptor(
                        UUID.fromString(
                                "00002902-0000-1000-8000-00805f9b34fb"
                        ))
                //0000fff4-0000-1000-8000-00805f9b34fb
                if(cccDescriptor!=null){
                  Log.e(TAG, "onServicesDiscovered: ${characteristic.uuid}")
//                  if(!cccDescriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)){
//                    Log.e(TAG, "cccDescriptor:setValue error ")
//                  }
                  val idata = ByteArray(8)
                  val buffer = ByteBuffer.wrap(idata).order(ByteOrder.LITTLE_ENDIAN)

                  buffer.putShort(0, 6.toShort()) // 连接间隔最小值

                  buffer.putShort(2, 12.toShort()) // 连接间隔最大值

                  buffer.putShort(4, 0.toShort()) // 从机延迟

                  buffer.putShort(6, 400.toShort()) // 连接超时和监视超时


                  if(!cccDescriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)){
                    Log.e(TAG, "cccDescriptor:setValue error ")
                  }
                  // 写入连接参数数据
                  // 写入连接参数数据
//                  cccDescriptor.value = idata
                  if (!gatt.writeDescriptor(cccDescriptor)){
                    Log.e(TAG, "gatt.writeDescriptor(cccDescriptor) error ")
                  }else{
                    Log.e(TAG, "gatt.writeDescriptor(cccDescriptor) success ")
                  }

                }
              }



            }
            if(characteristic.properties and BluetoothGattCharacteristic.PROPERTY_WRITE == BluetoothGattCharacteristic.PROPERTY_WRITE ){
              writeCharacteristicList.add(characteristic)
            }
            if(characteristic.properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE == BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE ){
              writeWithoutResponseCharacteristicsList.add(characteristic)
            }
          }
        }
        writeCharacteristics[uuid] = writeCharacteristicList
        writeWithoutResponseCharacteristics[uuid] = writeWithoutResponseCharacteristicsList
      }
    }

    override fun onCharacteristicChanged(
      gatt: BluetoothGatt?,
      characteristic: BluetoothGattCharacteristic?
    ) {
      super.onCharacteristicChanged(gatt, characteristic)
      if(gatt != null && characteristic != null){
        val data = characteristic.value
        invokeMethod("didReceiveData", mapOf(
          "uuid" to gatt.device.address,
          "characteristicUUID" to characteristic.uuid.toString(),
          "data" to data
        ))
      }
    }

    override fun onDescriptorWrite(
      gatt: BluetoothGatt?,
      descriptor: BluetoothGattDescriptor?,
      status: Int
    ) {
      super.onDescriptorWrite(gatt, descriptor, status)
    }

    override fun onCharacteristicRead(
      gatt: BluetoothGatt?,
      characteristic: BluetoothGattCharacteristic?,
      status: Int
    ) {
      super.onCharacteristicRead(gatt, characteristic, status)
    }

    override fun onCharacteristicWrite(
      gatt: BluetoothGatt?,
      characteristic: BluetoothGattCharacteristic?,
      status: Int
    ) {
      super.onCharacteristicWrite(gatt, characteristic, status)

      Log.e(TAG, "onDescriptorWrite: 写入数据完成  $status", )
      if(gatt != null&&characteristic!=null){
        if(status == BluetoothGatt.GATT_SUCCESS ){
        }else{
          var list = mutableListOf<BluetoothGattCharacteristic>()
          var arr = writeCharacteristics[gatt.device.address] ?: listOf()
          list.addAll(arr)
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            list.removeIf { it.uuid.equals(characteristic.uuid) }
          }else{
            ///TODO
          }
          writeCharacteristics[gatt.device.address] = list

          list = mutableListOf<BluetoothGattCharacteristic>()
          arr = writeWithoutResponseCharacteristics[gatt.device.address] ?: listOf()
          list.addAll(arr)
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            list.removeIf { it.uuid.equals(characteristic.uuid) }
          }else{
            ///TODO
          }
          writeWithoutResponseCharacteristics[gatt.device.address] = list
        }
      }
    }
  }

}
