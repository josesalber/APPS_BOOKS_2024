// Configuración de Firebase
const firebaseConfig = {
    apiKey: "AIzaSyBxKd8x07th27uwCEVX-MMxLJ3jH4dAR-s",
    authDomain: "apprendeplus-e226f.firebaseapp.com",
    projectId: "apprendeplus-e226f",
    storageBucket: "apprendeplus-e226f.appspot.com",
    messagingSenderId: "819355620126",
    appId: "1:819355620126:web:856cb1c5f7b3483f356f0f"
  };
  
  // Inicializar Firebase
  import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
  import { getAuth, signInWithEmailAndPassword, signOut } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";
  import { getFirestore, collection, addDoc, doc, getDoc } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-firestore.js";
  
  const app = initializeApp(firebaseConfig);
  const auth = getAuth(app);
  const db = getFirestore(app);
  
  // Elementos del DOM
  const loginContainer = document.getElementById('login-container');
  const addNewsContainer = document.getElementById('add-news-container');
  const loginButton = document.getElementById('login-button');
  const loginError = document.getElementById('login-error');
  const addNewsForm = document.getElementById('add-news-form');
  const addNewsError = document.getElementById('add-news-error');
  const addNewsSuccess = document.getElementById('add-news-success');
  
  // Iniciar sesión
  loginButton.addEventListener('click', () => {
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
  
    signInWithEmailAndPassword(auth, email, password)
      .then((userCredential) => {
        const user = userCredential.user;
        if (user) {
          // Verificar el rol del usuario
          const userDoc = doc(db, 'users', user.uid);
          getDoc(userDoc)
            .then((doc) => {
              if (doc.exists() && doc.data().role === 'admin') {
                loginContainer.classList.add('hidden');
                addNewsContainer.classList.remove('hidden');
              } else {
                Swal.fire({
                  icon: 'error',
                  title: 'Acceso denegado',
                  text: 'Solo los administradores pueden acceder.',
                  confirmButtonColor: '#d33',
                });
                signOut(auth);
              }
            })
            .catch((error) => {
              Swal.fire({
                icon: 'error',
                title: 'Error',
                text: 'Error al verificar el rol del usuario: ' + error.message,
                confirmButtonColor: '#d33',
              });
              signOut(auth);
            });
        }
      })
      .catch((error) => {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message,
          confirmButtonColor: '#d33',
        });
      });
  });
  
  // Agregar noticia
  addNewsForm.addEventListener('submit', (e) => {
    e.preventDefault();
  
    const banner = document.getElementById('banner').value;
    const title = document.getElementById('title').value;
    const info = document.getElementById('info').value;
    const link = document.getElementById('link').value;
    const adminId = auth.currentUser.uid;
    const adminEmail = auth.currentUser.email;
  
    addDoc(collection(db, 'Noticias'), {
      banner,
      title,
      info,
      link,
      adminId,
      adminEmail,
      timestamp: firebase.firestore.FieldValue.serverTimestamp()
    })
    .then(() => {
      Swal.fire({
        icon: 'success',
        title: 'Noticia agregada',
        text: 'La noticia ha sido agregada exitosamente.',
        confirmButtonColor: '#4CAF50',
      });
      addNewsForm.reset();
    })
    .catch((error) => {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: error.message,
        confirmButtonColor: '#d33',
      });
    });
  });