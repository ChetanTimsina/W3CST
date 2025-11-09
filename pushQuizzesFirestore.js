const admin = require("firebase-admin");
const quizzes = require("./quizzes.json"); // your JSON file

// Initialize Firebase Admin
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function pushQuizzes() {
  try {
    const quizzesRef = db.collection("Quizzes").doc("Allcourses");

    // directly store all courses as nested maps
    await quizzesRef.set(quizzes);

    console.log("🔥 Quizzes uploaded successfully to Firestore!");
  } catch (error) {
    console.error("❌ Error uploading quizzes:", error);
  }
}

pushQuizzes();
