const API_BASE_URL = 'http://localhost:3000/api';

const api = {
    async fetchWithLog(endpoint, options = {}) {
        const url = `${API_BASE_URL}${endpoint.startsWith('/') ? '' : '/'}${endpoint}`;
        console.log(`[API] Solicitando: ${url}`, options.method || 'GET');
        try {
            const response = await fetch(url, options);
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.error || `Error HTTP: ${response.status}`);
            }
            return await response.json();
        } catch (error) {
            console.error(`[API] Error en ${url}:`, error.message);
            throw error;
        }
    },

    async get(endpoint) {
        return this.fetchWithLog(endpoint);
    },

    async post(endpoint, data) {
        return this.fetchWithLog(endpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
    },

    async put(endpoint, data) {
        return this.fetchWithLog(endpoint, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
    }
};

window.api = api;
