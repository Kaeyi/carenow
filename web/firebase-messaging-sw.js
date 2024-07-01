importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

   /*Update with yours config*/
   const firebaseConfig = {
    apiKey: "AIzaSyClhlzFCoq-x7vTGyivKW_wRsHK_qlV8zw",
    authDomain: "carenow-kaeyi.firebaseapp.com",
    projectId: "carenow-kaeyi",
    storageBucket: "carenow-kaeyi.appspot.com",
    messagingSenderId: "55069246572",
    appId: "1:55069246572:web:8666a596d892b7f7ac4449"
  };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });