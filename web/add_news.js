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
import { getFirestore, collection, addDoc, doc, getDoc, updateDoc, deleteDoc, query, orderBy, getDocs, serverTimestamp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-firestore.js";

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// Elementos del DOM
const loginContainer = document.getElementById('login-container');
const addNewsContainer = document.getElementById('add-news-container');
const loginButton = document.getElementById('login-button');
const logoutButton = document.getElementById('logout-button');
const loginError = document.getElementById('login-error');
const addNewsForm = document.getElementById('add-news-form');
const addNewsError = document.getElementById('add-news-error');
const addNewsSuccess = document.getElementById('add-news-success');
const bannerInput = document.getElementById('banner');
const bannerPreview = document.getElementById('banner-preview');
const newsList = document.getElementById('news-list');
const submitButton = document.querySelector('button[type="submit"]');

let isEditing = false;
let currentNewsId = null;

// Verificar si los elementos del DOM están presentes
if (loginButton && logoutButton && addNewsForm && bannerInput) {
  // Inicializar Quill
  const quill = new Quill('#editor-container', {
    theme: 'snow',
    modules: {
      toolbar: [
        [{ 'header': [1, 2, false] }],
        ['bold', 'italic', 'underline'],
        ['link', 'blockquote', 'code-block'],
        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
        [{ 'script': 'sub'}, { 'script': 'super' }],
        [{ 'indent': '-1'}, { 'indent': '+1' }],
        [{ 'direction': 'rtl' }],
        [{ 'color': [] }, { 'background': [] }],
        [{ 'align': [] }],
        ['clean']
      ]
    }
  });

  // Previsualizar imagen del banner
  bannerInput.addEventListener('input', () => {
    const url = bannerInput.value;
    if (url) {
      bannerPreview.src = url;
      bannerPreview.classList.remove('hidden');
    } else {
      bannerPreview.src = '';
      bannerPreview.classList.add('hidden');
    }
  });

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
                Swal.fire({
                  icon: 'success',
                  title: 'Inicio de sesión exitoso',
                  text: 'Has iniciado sesión correctamente.',
                  confirmButtonColor: '#4CAF50',
                });
                loadNews();
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

  // Cerrar sesión
  logoutButton.addEventListener('click', () => {
    signOut(auth).then(() => {
      loginContainer.classList.remove('hidden');
      addNewsContainer.classList.add('hidden');
      Swal.fire({
        icon: 'success',
        title: 'Sesión cerrada',
        text: 'Has cerrado sesión correctamente.',
        confirmButtonColor: '#4CAF50',
      });
    }).catch((error) => {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: error.message,
        confirmButtonColor: '#d33',
      });
    });
  });

  // Agregar o actualizar noticia
  addNewsForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const banner = document.getElementById('banner').value;
    const title = document.getElementById('title').value;
    const info = quill.root.innerHTML;
    const link = document.getElementById('link').value;
    const adminId = auth.currentUser.uid;
    const adminEmail = auth.currentUser.email;

    if (isEditing && currentNewsId) {
      // Actualizar noticia existente
      const newsDoc = doc(db, 'Noticias', currentNewsId);
      updateDoc(newsDoc, {
        banner,
        title,
        info,
        link,
        adminId,
        adminEmail,
        status: 1, // Asegurarse de que la noticia esté activa
        timestamp: serverTimestamp()
      })
      .then(() => {
        Swal.fire({
          icon: 'success',
          title: 'Noticia actualizada',
          text: 'La noticia ha sido actualizada exitosamente.',
          confirmButtonColor: '#4CAF50',
        });
        resetForm();
        loadNews();
      })
      .catch((error) => {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message,
          confirmButtonColor: '#d33',
        });
      });
    } else {
      // Agregar nueva noticia
      addDoc(collection(db, 'Noticias'), {
        banner,
        title,
        info,
        link,
        adminId,
        adminEmail,
        status: 1, // Noticia activa por defecto
        timestamp: serverTimestamp()
      })
      .then(() => {
        Swal.fire({
          icon: 'success',
          title: 'Noticia agregada',
          text: 'La noticia ha sido agregada exitosamente.',
          confirmButtonColor: '#4CAF50',
        });
        resetForm();
        loadNews();
      })
      .catch((error) => {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message,
          confirmButtonColor: '#d33',
        });
      });
    }
  });

  // Cargar noticias
  function loadNews() {
    const q = query(collection(db, 'Noticias'), orderBy('timestamp', 'desc'));
    getDocs(q)
      .then((querySnapshot) => {
        newsList.innerHTML = '';
        querySnapshot.forEach((doc) => {
          const news = doc.data();
          const newsItem = document.createElement('div');
          newsItem.classList.add('news-item');
          if (news.status === 0) {
            newsItem.classList.add('deleted-news');
          }
          newsItem.innerHTML = `
            <h3>${news.title}</h3>
            <img src="${news.banner}" alt="Banner">
            <button onclick="showNewsDetails('${doc.id}')">Ver Detalles</button>
          `;
          newsList.appendChild(newsItem);
        });
      })
      .catch((error) => {
        console.error('Error al cargar noticias: ', error);
      });
  }

  // Mostrar detalles de la noticia en una ventana modal
  window.showNewsDetails = function(id) {
    const newsDoc = doc(db, 'Noticias', id);
    getDoc(newsDoc)
      .then((doc) => {
        if (doc.exists) {
          const news = doc.data();
          Swal.fire({
            title: news.title,
            html: `
              <img src="${news.banner}" alt="Banner" style="width: 100%; max-height: 200px; border-radius: 4px; margin-bottom: 10px;">
              <div>${news.info}</div>
              <a href="${news.link}" target="_blank">Leer más</a>
            `,
            showCancelButton: true,
            confirmButtonText: news.status === 1 ? 'Editar' : 'Restaurar',
            cancelButtonText: news.status === 1 ? 'Eliminar' : 'Eliminar Definitivamente',
            confirmButtonColor: '#4CAF50',
            cancelButtonColor: '#d33',
          }).then((result) => {
            if (result.isConfirmed) {
              if (news.status === 1) {
                editNews(id);
              } else {
                restoreNews(id);
              }
            } else if (result.dismiss === Swal.DismissReason.cancel) {
              if (news.status === 1) {
                deleteNews(id);
              } else {
                deleteNewsPermanently(id);
              }
            }
          });
        }
      })
      .catch((error) => {
        console.error('Error al mostrar detalles de la noticia: ', error);
      });
  }

  // Editar noticia
  window.editNews = function(id) {
    const newsDoc = doc(db, 'Noticias', id);
    getDoc(newsDoc)
      .then((doc) => {
        if (doc.exists) {
          const news = doc.data();
          document.getElementById('banner').value = news.banner;
          document.getElementById('title').value = news.title;
          quill.root.innerHTML = news.info;
          document.getElementById('link').value = news.link;
          bannerPreview.src = news.banner;
          bannerPreview.classList.remove('hidden');
          submitButton.textContent = 'Editar Noticia';
          isEditing = true;
          currentNewsId = id;
        }
      })
      .catch((error) => {
        console.error('Error al editar noticia: ', error);
      });
  }

  // Eliminar noticia (lógica)
  window.deleteNews = function(id) {
    const newsDoc = doc(db, 'Noticias', id);
    updateDoc(newsDoc, {
      status: 0,
      deletionTimestamp: serverTimestamp() // Agregar timestamp de eliminación
    })
      .then(() => {
        Swal.fire({
          icon: 'success',
          title: 'Noticia eliminada',
          text: 'La noticia ha sido marcada como eliminada.',
          confirmButtonColor: '#4CAF50',
        });
        loadNews();
      })
      .catch((error) => {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message,
          confirmButtonColor: '#d33',
        });
      });
  }

  // Restaurar noticia
  window.restoreNews = function(id) {
    const newsDoc = doc(db, 'Noticias', id);
    updateDoc(newsDoc, {
      status: 1,
      deletionTimestamp: null // Eliminar timestamp de eliminación
    })
      .then(() => {
        Swal.fire({
          icon: 'success',
          title: 'Noticia restaurada',
          text: 'La noticia ha sido restaurada.',
          confirmButtonColor: '#4CAF50',
        });
        loadNews();
      })
      .catch((error) => {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message,
          confirmButtonColor: '#d33',
        });
      });
  }

  // Eliminar noticia físicamente
  window.deleteNewsPermanently = function(id) {
    const newsDoc = doc(db, 'Noticias', id);
    deleteDoc(newsDoc)
      .then(() => {
        Swal.fire({
          icon: 'success',
          title: 'Noticia eliminada definitivamente',
          text: 'La noticia ha sido eliminada de la base de datos.',
          confirmButtonColor: '#4CAF50',
        });
        loadNews();
      })
      .catch((error) => {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message,
          confirmButtonColor: '#d33',
        });
      });
  }

  // Restablecer el formulario
  function resetForm() {
    addNewsForm.reset();
    quill.root.innerHTML = '';
    bannerPreview.src = '';
    bannerPreview.classList.add('hidden');
    submitButton.textContent = 'Publicar Noticia';
    isEditing = false;
    currentNewsId = null;
  }

  // Guardar el manejador original del formulario
  const addNewsFormSubmitHandler = addNewsForm.onsubmit;
}