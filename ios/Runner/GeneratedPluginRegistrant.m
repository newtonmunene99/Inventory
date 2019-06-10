//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <cloud_firestore/CloudFirestorePlugin.h>
#import <connectivity/ConnectivityPlugin.h>
#import <firebase_auth/FirebaseAuthPlugin.h>
#import <firebase_core/FirebaseCorePlugin.h>
#import <google_sign_in/GoogleSignInPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTCloudFirestorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTCloudFirestorePlugin"]];
  [FLTConnectivityPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTConnectivityPlugin"]];
  [FLTFirebaseAuthPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseAuthPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [FLTGoogleSignInPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleSignInPlugin"]];
}

@end
