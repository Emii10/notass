// Weather API configuration
const API_KEY = process.env.OPENWEATHER_API_KEY || '';

async function getWeatherData() {
    try {
        const response = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=Mexico City,MX&appid=${API_KEY}&units=metric&lang=es`);
        const data = await response.json();
        
        if (response.ok) {
            return {
                success: true,
                city: 'Ciudad de México',
                temperature: Math.round(data.main.temp),
                description: data.weather[0].description,
                feelsLike: Math.round(data.main.feels_like),
                humidity: data.main.humidity,
                windSpeed: Math.round(data.wind.speed * 3.6)
            };
        } else {
            return { success: false, error: 'API error' };
        }
    } catch (error) {
        return { success: false, error: 'Network error' };
    }
}

// Export for use in HTML
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { getWeatherData };
}