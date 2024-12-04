import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";
import { getFirestore, collection, getDocs, query, where } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "AIzaSyBxKd8x07th27uwCEVX-MMxLJ3jH4dAR-s",
  authDomain: "apprendeplus-e226f.firebaseapp.com",
  projectId: "apprendeplus-e226f",
  storageBucket: "apprendeplus-e226f.appspot.com",
  messagingSenderId: "819355620126",
  appId: "1:819355620126:web:856cb1c5f7b3483f356f0f"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

let chart; // Variable para almacenar el gráfico

document.getElementById('generate-report-button').addEventListener('click', async () => {
  const reportContent = document.getElementById('report-content');
  const reportDate = document.getElementById('report-date');
  const reportStats = document.getElementById('report-stats');
  const reportChart = document.getElementById('report-chart');

  const now = new Date();
  reportDate.textContent = `Fecha del reporte: ${now.toLocaleDateString()} ${now.toLocaleTimeString()}`;

  try {
    const stats = await generateReport();
    reportStats.innerHTML = `
      <table class="report-table">
        <tr><th>Métrica</th><th>Cantidad</th></tr>
        <tr><td>Noticias publicadas</td><td>${stats.publishedNews}</td></tr>
        <tr><td>Noticias eliminadas</td><td>${stats.deletedNews}</td></tr>
        <tr><td>Usuarios registrados</td><td>${stats.users}</td></tr>
        <tr><td>Preferencias más comunes</td><td>${stats.commonPreferences.join(', ')}</td></tr>
        <tr><td>Libros guardados</td><td>${stats.savedBooks}</td></tr>
        <tr><td>Cursos guardados</td><td>${stats.savedCourses}</td></tr>
        <tr><td>Categoría de curso más guardada</td><td>${stats.mostSavedCourseCategory}</td></tr>
        <tr><td>Categoría de libro más guardada</td><td>${stats.mostSavedBookCategory}</td></tr>
        <tr><td>Universidades más seleccionadas</td><td>${stats.mostSelectedUniversities.join(', ')}</td></tr>
        <tr><td>Edad promedio de los usuarios</td><td>${stats.averageAge}</td></tr>
        <tr><td>Edad menor de los usuarios</td><td>${stats.minAge}</td></tr>
      </table>
    `;

    const chartData = {
      labels: ['Noticias publicadas', 'Noticias eliminadas', 'Usuarios registrados', 'Libros guardados', 'Cursos guardados'],
      datasets: [{
        label: 'Estadísticas',
        data: [stats.publishedNews, stats.deletedNews, stats.users, stats.savedBooks, stats.savedCourses],
        backgroundColor: ['#4CAF50', '#FF5733', '#33B5E5', '#FFC107', '#9C27B0']
      }]
    };

    // Destruir el gráfico existente si existe
    if (chart) {
      chart.destroy();
    }

    chart = new Chart(reportChart, {
      type: 'bar',
      data: chartData,
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'top',
          },
          title: {
            display: true,
            text: 'Estadísticas de Administración'
          }
        }
      }
    });

    reportContent.classList.remove('hidden');
  } catch (error) {
    console.error('Error al generar el reporte: ', error);
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'Error al generar el reporte: ' + error.message,
      confirmButtonColor: '#d33',
    });
  }
});

async function generateReport() {
  const publishedNewsQuery = query(collection(db, 'Noticias'), where('status', '==', 1));
  const deletedNewsQuery = query(collection(db, 'Noticias'), where('status', '==', 0));
  const usersQuery = collection(db, 'users');

  const [publishedNewsSnapshot, deletedNewsSnapshot, usersSnapshot] = await Promise.all([
    getDocs(publishedNewsQuery),
    getDocs(deletedNewsQuery),
    getDocs(usersQuery)
  ]);

  const publishedNews = publishedNewsSnapshot.size;
  const deletedNews = deletedNewsSnapshot.size;
  const users = usersSnapshot.size;

  const preferences = usersSnapshot.docs.map(doc => doc.data().user_data?.preferences || []);
  const commonPreferences = preferences.flat().reduce((acc, pref) => {
    acc[pref] = (acc[pref] || 0) + 1;
    return acc;
  }, {});
  const commonPreferencesArray = Object.entries(commonPreferences).sort((a, b) => b[1] - a[1]).map(([key]) => key);

  const savedBooks = usersSnapshot.docs.reduce((acc, doc) => acc + (doc.data().favorites ? doc.data().favorites.length : 0), 0);
  const savedCourses = usersSnapshot.docs.reduce((acc, doc) => acc + (doc.data().courses ? doc.data().courses.length : 0), 0);

  const savedBooksData = usersSnapshot.docs.flatMap(doc => doc.data().favorites || []);
  const savedCoursesData = usersSnapshot.docs.flatMap(doc => doc.data().courses || []);

  const bookCategories = savedBooksData.reduce((acc, book) => {
    if (book.genre) {
      acc[book.genre] = (acc[book.genre] || 0) + 1;
    }
    return acc;
  }, {});
  const mostSavedBookCategory = Object.entries(bookCategories).sort((a, b) => b[1] - a[1])[0]?.[0] || 'N/A';

  const courseCategories = savedCoursesData.reduce((acc, course) => {
    if (course.category) {
      acc[course.category] = (acc[course.category] || 0) + 1;
    }
    return acc;
  }, {});
  const mostSavedCourseCategory = Object.entries(courseCategories).sort((a, b) => b[1] - a[1])[0]?.[0] || 'N/A';

  const universities = usersSnapshot.docs.map(doc => doc.data().university).filter(Boolean);
  const universityCounts = universities.reduce((acc, university) => {
    acc[university] = (acc[university] || 0) + 1;
    return acc;
  }, {});
  const mostSelectedUniversities = Object.entries(universityCounts).sort((a, b) => b[1] - a[1]).map(([key]) => key);

  const ages = usersSnapshot.docs.map(doc => doc.data().age).filter(Boolean);
  const averageAge = ages.reduce((acc, age) => acc + age, 0) / ages.length;
  const minAge = Math.min(...ages);

  return {
    publishedNews,
    deletedNews,
    users,
    commonPreferences: commonPreferencesArray,
    savedBooks,
    savedCourses,
    mostSavedBookCategory,
    mostSavedCourseCategory,
    mostSelectedUniversities,
    averageAge: averageAge.toFixed(2),
    minAge
  };
}