import * as functions from "firebase-functions";
//import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";
//admin.initializeApp();
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
export const sendEmployeeInvite = functions.firestore
  .document("employees/{email}")
  .onCreate((snap: FirebaseFirestore.DocumentSnapshot, context) => {
    const employee: any = snap.data();

    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: "newtonmunenecodes@gmail.com",
        pass: "Itsmunene1999"
      }
    });

    const mailOptions = {
      from: "Newton Munene <newtonmunenecodes@gmail.com>",
      to: employee.email,
      subject: "Invitation to OFM Kenya",
      html: ` <h4>Dear ${employee.name},</h4>
    <br>
    <p>We invite you to register in our new inventory app. This app is aimed at reducing your work load and immproving management of sales data/information. You can download the app from <a href="">here.</a> Once downloaded please remember to first register before logging in.</p>
    <p>Thank You.</p>
    <p><b><i>Organic Farmer's Market</i></b></p>`
    };

    transporter.sendMail(mailOptions, (err, info) => {
      if (err) {
        console.log(err);
      } else {
        console.log(info);
      }
    });
  });
