import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';

bool started = false;
String errors = '';
String RAMGB = '0';
String AOSPURL = '';
String AOSPbranch = '';
String processosrun = '';
String URLDevice = '';
String DeviceKernelURL = '';
String DeviceName = '';
String vendorURL = '';
String BrandName = '';
bool AOSPExists = false;
bool isInProcess = false;
List<String> ListadeLogs = [];

void main(){
  runApp(
    MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true
      ),
      home: const mainActivity(),
    ),
  );
}

class mainActivity extends StatefulWidget {
 
  const mainActivity({super.key});

  @override
  State<mainActivity> createState() => _mainActivityState();
}

class _mainActivityState extends State<mainActivity> {

  verifyRAM() async {

    await Future.delayed(const Duration(seconds: 1));
    String command = 'grep MemTotal /proc/meminfo';
    ProcessResult result = await Process.run('bash', ['-c', command]);

    String error = result.stderr;
    String processo = result.stdout;

    String processotratado = processo.replaceAll("MemTotal", "").replaceAll("  ", "").replaceAll(" ", "").replaceAll("kB", "").replaceAll(":", "").trim();

    int ramKB = int.parse(processotratado);

    double ramGB = double.parse("$ramKB")/1000000;

    setState(() {
      RAMGB = ramGB.toStringAsFixed(0);
    });

    print("Resultado: ${ramGB.toStringAsFixed(0)}");
    print('Error: $error');
  }

  verifyisExists() async {
    await Future.delayed(const Duration(seconds: 1));
    String command = 'cd / ; cd AOSP';
    ProcessResult result = await Process.run('bash', ['-c', command]);

    String error = result.stderr;
    String processo = result.stdout;

    print("Resultado: $processo");
    print('Error: $error');

    if(error.contains('Arquivo ou diretório inexistente')){
      setState(() {
        AOSPExists = false;
      });
    }else{
      if(error.contains('Missing file or directory')){
        setState(() {
          AOSPExists = false;
        });
      }else{
        setState(() {
          AOSPExists = true;
        });
      }
    }

  }

  desableRAMDesableUbuntu() async {
    String command = 'systemctl disable --now systemd-oomd';
    ProcessResult result = await Process.run('bash', ['-c', command]);

    String error = result.stderr;
    String processo = result.stdout;

    print("Resultado: $processo");
    print('Error: $error');
  }

  runTime(String command) async {
    ProcessResult result = await Process.run('bash', ['-c', command]);

    String error = result.stderr;
    String processo = result.stdout;

    Navigator.of(context).pop();
    print("Resultado: $processo");
    print('Error: $error');

    setState(() {
      errors = error;
    });
  }


  @override
  Widget build(BuildContext context) {

    startedfun(){
      if(started == false){
        verifyRAM();
        desableRAMDesableUbuntu();
        verifyisExists();
      }
    }

    startedfun();
    started = true;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('AOSP Ease Build'),
        backgroundColor: Colors.green[900],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isInProcess == true ? Container(padding: const EdgeInsets.all(16),child: const CircularProgressIndicator(),): Container(),
                  Text('Process: $processosrun'),
                ],
              ),
              Text('Alert/Error: $errors'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(int.parse(RAMGB) < 16? Icons.close: Icons.done),
                  Text("Total RAM: ${RAMGB}GB")
                ],
              ),
              ElevatedButton(onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      title: Text('Wait, we are installing all dependencies on your machine!'),
                      actions: [
                        Center(
                          child: CircularProgressIndicator(),
                        )
                      ],
                    );
                  },
                );

                String command = 'apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev repo unzip openjdk-11-jdk python2 python3 -y ; git lfs install';
                ProcessResult result = await Process.run('bash', ['-c', command]);

                String error = result.stderr;
                String processo = result.stdout;

                Navigator.of(context).pop();
                FlutterToastr.show("Done!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                print("Resultado: $processo");
                print('Error: $error');

                setState(() {
                  ListadeLogs.add(result.stdout);
                  errors = error;
                });

                }, child: const Text('Install dependencies')
              ),
              AOSPExists == false ?  Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      keyboardType: TextInputType.url,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: (value){
                        setState(() {
                          AOSPURL = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Manifest of the AOSP',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      keyboardType: TextInputType.url,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: (value){
                        setState(() {
                          AOSPbranch = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Github repository branch',
                      ),
                    ),
                  ),
                  ElevatedButton(onPressed: () async {
                    if(AOSPURL == ''){
                      FlutterToastr.show("The AOSP URL is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                    }else{
                      if(AOSPbranch == ''){
                        FlutterToastr.show("The AOSP branch is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                      }else{
                        //Iniciar o repo init
                        setState(() {
                          processosrun = 'Making the directory and doing the repo init';
                          isInProcess = true;
                        });

                        String command = 'cd / ; mkdir AOSP ; cd /AOSP ';
                        String command2 = 'git config --global user.email "aosp@build.com"';
                        String command3 = 'git config --global user.name "AOSPBuilder"';
                        String command4 = 'repo init -u $AOSPURL -b $AOSPbranch';

                        String finalCommand = '$command ; $command2 ; $command3 ; $command4';

                        ProcessResult result = await Process.run('bash', ['-c', finalCommand]);

                        String error = result.stderr;
                        String processo = result.stdout;

                        print("Resultado: $processo");
                        print('Error: $error');

                        setState(() {
                          ListadeLogs.add(result.stdout);
                          errors = error;
                          isInProcess = false;
                        });

                        FlutterToastr.show("First steps completed! Doing the repo sync!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);

                        setState(() {
                          processosrun = 'Doing the repo sync';
                          isInProcess = true;
                        });

                        String command5 = 'cd / ; cd AOSP';
                        String command6 = 'repo sync -c -j\$(nproc --all) --force-sync --no-clone-bundle --no-tags';
                        String finalCommand2 = '$command5 ; $command6';

                        ProcessResult result2 = await Process.run('bash', ['-c', finalCommand2]);

                        String error2 = result2.stderr;
                        String processo2 = result2.stdout;

                        print("Resultado: $processo2");
                        print('Error: $error2');

                        setState(() {
                          ListadeLogs.add(result2.stdout);
                          errors = error;
                          isInProcess = false;
                          processosrun = 'AOSP Downloaded!';
                          AOSPExists = true;
                        });

                        FlutterToastr.show("Done! See the log and continue.", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                      }
                    }
                  }, child: const Text('Clone AOSP')
                  ),
                ],
              ): Container(),
              //Device containers
              AOSPExists == true ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      keyboardType: TextInputType.url,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: (value){
                        setState(() {
                          DeviceName = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Device name',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      keyboardType: TextInputType.url,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: (value){
                        setState(() {
                          BrandName = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Brand name',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      keyboardType: TextInputType.url,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: (value){
                        setState(() {
                          URLDevice = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Device github',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            title: Text('Cloning Device!'),
                            actions: [
                              Center(
                                child: CircularProgressIndicator(),
                              )
                            ],
                          );
                        },
                      );
                      if(URLDevice == ''){
                        FlutterToastr.show("URL Device is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);

                      }else{
                        if(DeviceName == ''){
                          FlutterToastr.show("Device name is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                        }else{
                          if(BrandName == ''){
                            FlutterToastr.show("Brand is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                          }else{

                            String command = 'cd /AOSP/device ; git clone $URLDevice $BrandName/$DeviceName';
                            ProcessResult result = await Process.run('bash', ['-c', command]);

                            String error = result.stderr;
                            String processo = result.stdout;

                            Navigator.of(context).pop();
                            FlutterToastr.show("Done!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                            print("Resultado: $processo");
                            print('Error: $error');

                            setState(() {
                              ListadeLogs.add(error);
                              errors = error;
                            });
                          }
                        }
                      }
                    }, child: const Text('Clone Device')
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      keyboardType: TextInputType.url,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: (value){
                        setState(() {
                          DeviceKernelURL = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Device Kernel Github',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            title: Text('Cloning Kernel!'),
                            actions: [
                              Center(
                                child: CircularProgressIndicator(),
                              )
                            ],
                          );
                        },
                      );
                      if(DeviceKernelURL == ''){
                        FlutterToastr.show("URL Kernel is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);

                      }else{
                        if(DeviceName == ''){
                          FlutterToastr.show("Device name is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                        }else{
                          if(BrandName == ''){
                            FlutterToastr.show("Brand is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                          }else{
                            String command = 'cd /AOSP/kernel ; git clone $DeviceKernelURL $BrandName/$DeviceName';
                            ProcessResult result = await Process.run('bash', ['-c', command]);

                            String error = result.stderr;
                            String processo = result.stdout;

                            Navigator.of(context).pop();
                            FlutterToastr.show("Done!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                            print("Resultado: $processo");
                            print('Error: $error');

                            setState(() {
                              ListadeLogs.add(error);
                              errors = error;
                            });
                          }
                        }
                      }
                    }, child: const Text('Clone Kernel')
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      keyboardType: TextInputType.url,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: (value){
                        setState(() {
                          vendorURL = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Device Vendor Github',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(onPressed: () async {
                      if(vendorURL == ''){
                        FlutterToastr.show("URL vendor is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                      } else{
                        if(DeviceName == ''){
                          FlutterToastr.show("Device name is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                        }else{
                          if(BrandName == ''){
                            FlutterToastr.show("Brand is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                          }else{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  title: Text('Cloning Vendor!'),
                                  actions: [
                                    Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  ],
                                );
                              },
                            );
                            String command = 'cd /AOSP/vendor ; git clone $vendorURL $BrandName/$DeviceName';

                            ProcessResult result = await Process.run('bash', ['-c', command]);

                            String error = result.stderr;
                            String processo = result.stdout;

                            Navigator.of(context).pop();
                            FlutterToastr.show("Done!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                            print("Resultado: $processo");
                            print('Error: $error');

                            setState(() {
                              ListadeLogs.add(error);
                              errors = error;
                            });
                          }
                        }
                      }
                    }, child: const Text('Clone Vendor')
                    ),
                  ),
                ],
              ) : Container(),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text('Always remember to go to the device, kernel or vendor folder to make changes if possible.'),
                ),
              ),
              //Memory and build containers
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        title: Text('We add more Swap memory!'),
                        actions: [
                          Center(
                            child: CircularProgressIndicator(),
                          )
                        ],
                      );
                    },
                  );

                  String command = 'sudo fallocate -l 32G /swapfile ; ls -lh /swapfile ; sudo chmod 600 /swapfile ; ls -lh /swapfile ; sudo mkswap /swapfile ; sudo swapon --show ; free -h ; echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab';
                  ProcessResult result = await Process.run('bash', ['-c', command]);

                  String error = result.stderr;
                  String processo = result.stdout;

                  Navigator.of(context).pop();
                  FlutterToastr.show("Done, reboot your machine!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                  print("Resultado: $processo");
                  print('Error: $error');

                  setState(() {
                    ListadeLogs.add(result.stdout);
                    errors = error;
                  });

                }, child: const Text('Add Swap Memory')
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(onPressed: AOSPExists == true ? () async {

                  if(DeviceName == ''){
                    FlutterToastr.show("The device name is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                  }else{
                    if(BrandName == ''){
                      FlutterToastr.show("The brand name is empty!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                    }else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            title: Text('Wait, building AOSP...'),
                            actions: [
                              Center(
                                child: CircularProgressIndicator(),
                              )
                            ],
                          );
                        },
                      );
                      String command = 'cd /AOSP ; . build/envsetup.sh ; lunch ${DeviceName}_user ; m';
                      ProcessResult result = await Process.run('bash', ['-c', command]);

                      String error = result.stderr;
                      String processo = result.stdout;
                      Navigator.of(context).pop();
                      FlutterToastr.show("Done!", context, duration: FlutterToastr.lengthShort, position:  FlutterToastr.bottom);
                      print("Resultado: $processo");
                      print('Error: $error');
                      setState(() {
                        ListadeLogs.add(result.stdout);
                        ListadeLogs.add(error);
                        errors = error;
                      });
                    }
                  }
                }: null, child: const Text('Build your AOSP')
                ),
              ),
            ],
          ),
        ),
      ),
        drawer: Drawer(
          child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Text('LOGS:')
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        height: 500,
                        child: ListView.builder(
                          itemCount: ListadeLogs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(ListadeLogs[index]),
                            );
                          },
                        ),
                      )
                  ),
                ],
              )
          ),
        ),
    );
  }
}
