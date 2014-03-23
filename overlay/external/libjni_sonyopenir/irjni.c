#include "irjni.h"
#include "libsonyir.h"
#include <unistd.h>

#include <android/log.h>

#define LOG_TAG "libsonyir_jni"
#define LOGI(fmt, args...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, fmt, ##args)
#define LOGD(fmt, args...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, fmt, ##args)
#define LOGE(fmt, args...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, fmt, ##args)

#define SLEEPTIME 2000

JNIEXPORT jint JNICALL Java_com_sssemil_sonyirremote_ir_ir_startIR
  (JNIEnv * je, jobject jo){

   int status = IRpowerOn(1);
   usleep(SLEEPTIME);
   status = IRserialOpen();
   usleep(SLEEPTIME);
   IRkickStart();
   usleep(SLEEPTIME);


   /*
   char *data = (char*) IRlearnKeyData();

   LOGI("%s : test! %s\n",__func__,data);

   free(data);*/



   return 1;

}


JNIEXPORT jint JNICALL Java_com_sssemil_sonyirremote_ir_ir_stopIR
  (JNIEnv * je, jobject jo){

   usleep(SLEEPTIME*10);
   int status = IRserialClose();
   usleep(SLEEPTIME);
   status = IRpowerOn(0);
   return 1;

}

JNIEXPORT jint JNICALL Java_com_sssemil_sonyirremote_ir_ir_learnKey
  (JNIEnv * je, jobject jo, jstring js){

  const char *filename = (*je)->GetStringUTFChars(je, js, 0);

  int ret = IRlearnKeyToFile(filename);

  LOGI("%s : filename %s\n",__func__,filename);

  (*je)->ReleaseStringUTFChars(je, js, filename);

  return ret;
}


JNIEXPORT jint JNICALL Java_com_sssemil_sonyirremote_ir_ir_sendKey
  (JNIEnv * je, jobject jo, jstring js){

  const char *filename = (*je)->GetStringUTFChars(je, js, 0);

  int ret = IRsendKeyFromFile(filename);

  LOGI("%s : filename %s\n",__func__,filename);

  (*je)->ReleaseStringUTFChars(je, js, filename);

  return ret;

}
