
const calendarData = [
    {
        "subject": "Team Meeting",
        "date": "15/09/24",
        "hour": "10:00",
        "link": "https://example.com/meeting1"
    },
    {
        "subject": "Project Deadline",
        "date": "20/09/24",
        "hour": "17:00",
        "link": "https://example.com/project1"
    },
    {
        "subject": "Lunch with Client",
        "date": "25/09/24",
        "hour": "12:30",
        "link": "https://example.com/lunch1"
    },
    {
        "subject": "Conference Call",
        "date": "28/09/24",
        "hour": "14:00",
        "link": "https://example.com/call1"
    },
    {
        "subject": "Training Session",
        "date": "28/09/24",
        "hour": "09:00",
        "link": "https://example.com/training1"
    }
];

let currentYear = 2024;
let currentMonth = 8; // September (0-indexed)

function generateCalendar(year, month) {
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startingDay = firstDay.getDay();

    let calendarHTML = '<div class="calendar">';
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // Add day names
    dayNames.forEach(day => {
        calendarHTML += `<div class="day-header">${day}</div>`;
    });

    // Add empty cells for days before the first of the month
    for (let i = 0; i < startingDay; i++) {
        calendarHTML += '<div class="day"></div>';
    }

    // Add days and events
    for (let day = 1; day <= daysInMonth; day++) {
        const currentDate = `${day.toString().padStart(2, '0')}/${(month + 1).toString().padStart(2, '0')}/${year.toString().slice(-2)}`;
        const events = calendarData.filter(event => event.date === currentDate);

        calendarHTML += `<div class="day">
                    <div class="day-header">${day}</div>`;

        events.slice(0, 4).forEach(event => {
            calendarHTML += `<div class="event" title="${event.subject}">
                        <a href="${event.link}" target="_blank">${event.hour} - ${event.subject}</a>
                    </div>`;
        });

        if (events.length > 4) {
            calendarHTML += `<div class="more-events">+${events.length - 4} more</div>`;
        }

        calendarHTML += '</div>';
    }

    calendarHTML += '</div>';
    return calendarHTML;
}

function updateCalendar() {
    document.getElementById('calendar').innerHTML = generateCalendar(currentYear, currentMonth);
    const monthNames = ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"];
    document.getElementById('currentMonth').textContent = `${monthNames[currentMonth]} ${currentYear}`;
}

document.getElementById('prevMonth').addEventListener('click', () => {
    currentMonth--;
    if (currentMonth < 0) {
        currentMonth = 11;
        currentYear--;
    }
    updateCalendar();
});

document.getElementById('nextMonth').addEventListener('click', () => {
    currentMonth++;
    if (currentMonth > 11) {
        currentMonth = 0;
        currentYear++;
    }
    updateCalendar();
});

// Initial calendar generation
updateCalendar();
