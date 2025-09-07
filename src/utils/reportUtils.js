// Rapor yardımcı fonksiyonları

export function getRecentIncidents(heartbeatList, monitors, days) {
    const incidents = [];
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);
    
    monitors.forEach(monitor => {
        if (heartbeatList[monitor.id]) {
            heartbeatList[monitor.id].forEach(heartbeat => {
                if (heartbeat.status === 0 && new Date(heartbeat.time) >= cutoffDate) {
                    incidents.push({
                        monitorId: monitor.id,
                        monitorName: monitor.name,
                        timestamp: heartbeat.time,
                        duration: heartbeat.duration || 0,
                        type: 'downtime'
                    });
                }
            });
        }
    });
    
    return incidents.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
}

export function showReportOptions(reportData, callback) {
    const options = [
        { name: "PDF Rapor", format: "pdf", icon: "file-pdf" },
        { name: "Excel Rapor", format: "excel", icon: "file-excel" },
        { name: "HTML Rapor", format: "html", icon: "file-code" },
        { name: "JSON Veri", format: "json", icon: "file-code" }
    ];
    
    // Basit prompt ile seçim (daha sonra modal ile değiştirilebilir)
    const choice = prompt(`Rapor formatı seçin:\n1. PDF Rapor\n2. Excel Rapor\n3. HTML Rapor\n4. JSON Veri\n\nNumara girin (1-4):`);
    
    if (choice && choice >= 1 && choice <= 4) {
        const selectedOption = options[choice - 1];
        callback(reportData, selectedOption.format);
    }
}

export function showExportOptions(callback) {
    const options = [
        { name: "Excel (.xlsx)", format: "excel", icon: "file-excel" },
        { name: "CSV (.csv)", format: "csv", icon: "file-csv" },
        { name: "JSON (.json)", format: "json", icon: "file-code" },
        { name: "XML (.xml)", format: "xml", icon: "file-code" }
    ];
    
    const choice = prompt(`Export formatı seçin:\n1. Excel (.xlsx)\n2. CSV (.csv)\n3. JSON (.json)\n4. XML (.xml)\n\nNumara girin (1-4):`);
    
    if (choice && choice >= 1 && choice <= 4) {
        const selectedOption = options[choice - 1];
        callback(selectedOption.format);
    }
}

export function generateHTMLContent(reportData) {
    return `
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>BeyzTrack Monitoring Raporu</title>
    <style>
        @page {
            margin: 2cm;
            size: A4;
        }
        
        * {
            box-sizing: border-box;
        }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            margin: 0; 
            padding: 0;
            background: #ffffff;
            color: #333;
            line-height: 1.6;
        }
        
        .watermark {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-45deg);
            opacity: 0.03;
            font-size: 8rem;
            font-weight: bold;
            color: #007bff;
            z-index: -1;
            pointer-events: none;
        }
        
        .watermark-triangle {
            position: fixed;
            top: 20%;
            left: 10%;
            transform: rotate(-15deg);
            opacity: 0.02;
            z-index: -1;
            pointer-events: none;
        }
        
        .watermark-triangle svg {
            width: 200px;
            height: 200px;
            fill: #007bff;
        }
        
        .watermark-center {
            position: fixed;
            top: 10%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-45deg);
            opacity: 0.15;
            z-index: -1;
            pointer-events: none;
        }
        
        .watermark-center svg {
            width: 400px;
            height: 400px;
            fill: #007bff;
        }
        
        .header { 
            text-align: center; 
            margin-bottom: 40px; 
            padding: 50px 0 30px 0;
            background: linear-gradient(135deg, #007bff, #0056b3);
            color: white;
            border-radius: 15px;
            position: relative;
            overflow: hidden;
        }
        
        .header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="2" fill="rgba(255,255,255,0.1)"/></svg>') repeat;
            animation: float 20s infinite linear;
        }
        
        @keyframes float {
            0% { transform: translateX(-50px) translateY(-50px); }
            100% { transform: translateX(50px) translateY(50px); }
        }
        
        .logo {
            position: absolute;
            top: -30px;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 80px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 10px;
            border: 3px solid rgba(255, 255, 255, 1);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            z-index: 10;
        }
        
        .logo img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }
        
        .header h1 {
            margin: 0 0 10px 0;
            font-size: 2rem;
            font-weight: 700;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .header .subtitle {
            font-size: 1.1rem;
            opacity: 0.9;
            margin: 5px 0;
        }
        
        .summary { 
            background: linear-gradient(135deg, #f8f9fa, #e9ecef); 
            padding: 30px; 
            border-radius: 15px; 
            margin-bottom: 30px;
            border-left: 5px solid #007bff;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .summary h2 {
            color: #007bff;
            margin-top: 0;
            font-size: 1.5rem;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .stat-item {
            background: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-top: 4px solid #007bff;
        }
        
        .stat-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: #007bff;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #666;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .monitor-table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-bottom: 30px;
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .monitor-table th { 
            background: linear-gradient(135deg, #007bff, #0056b3);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size: 0.9rem;
        }
        
        .monitor-table td { 
            padding: 15px;
            border-bottom: 1px solid #eee;
            transition: background-color 0.2s;
        }
        
        .monitor-table tr:hover td {
            background-color: #f8f9fa;
        }
        
        .monitor-table tr:last-child td {
            border-bottom: none;
        }
        
        .status-active { 
            color: #28a745; 
            font-weight: bold;
            background: rgba(40, 167, 69, 0.1);
            padding: 5px 10px;
            border-radius: 20px;
            display: inline-block;
        }
        
        .status-inactive { 
            color: #dc3545; 
            font-weight: bold;
            background: rgba(220, 53, 69, 0.1);
            padding: 5px 10px;
            border-radius: 20px;
            display: inline-block;
        }
        
        .uptime-bar {
            background: #e9ecef;
            border-radius: 10px;
            height: 8px;
            margin: 5px 0;
            overflow: hidden;
        }
        
        .uptime-fill {
            height: 100%;
            background: linear-gradient(90deg, #28a745, #20c997);
            border-radius: 10px;
            transition: width 0.3s ease;
        }
        
        .system-health {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .health-item {
            background: white;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            border-top: 4px solid #28a745;
        }
        
        .health-item.performance {
            border-top-color: #ffc107;
        }
        
        .health-item.reliability {
            border-top-color: #17a2b8;
        }
        
        .health-value {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .health-item.overall .health-value {
            color: #28a745;
        }
        
        .health-item.performance .health-value {
            color: #ffc107;
        }
        
        .health-item.reliability .health-value {
            color: #17a2b8;
        }
        
        .footer {
            margin-top: 40px;
            padding: 20px;
            text-align: center;
            background: #f8f9fa;
            border-radius: 10px;
            color: #666;
            font-size: 0.9rem;
        }
        
        .footer .brand {
            font-weight: bold;
            color: #007bff;
        }
        
        @media print {
            .watermark {
                opacity: 0.1;
            }
            
            .header {
                background: #007bff !important;
                -webkit-print-color-adjust: exact;
                color-adjust: exact;
            }
            
            .monitor-table th {
                background: #007bff !important;
                -webkit-print-color-adjust: exact;
                color-adjust: exact;
            }
        }
    </style>
</head>
<body>
    <div class="watermark">BEYZTRACK</div>
    <div class="watermark-triangle">
        <svg viewBox="0 0 100 100" style="width: 200px; height: 200px;">
            <path d="M50 10 L90 80 L10 80 Z" fill="#007bff" stroke="#007bff" stroke-width="2"/>
        </svg>
    </div>
    <div class="watermark-center">
        <svg viewBox="0 0 100 100" style="width: 400px; height: 400px;">
            <path d="M50 10 L90 80 L10 80 Z" fill="#007bff" stroke="#007bff" stroke-width="3"/>
        </svg>
    </div>
    
    <div class="header">
        <div class="logo">
            <img src="/1.png" alt="BeyzTrack Logo" style="width: 100%; height: 100%; object-fit: contain;"/>
        </div>
        <h1>BeyzTrack Monitoring Raporu</h1>
        <div class="subtitle">Oluşturulma Tarihi: ${new Date(reportData.generatedAt).toLocaleString('tr-TR')}</div>
        <div class="subtitle">Rapor Dönemi: ${reportData.period}</div>
    </div>
    
    <div class="summary">
        <h2>📊 Özet İstatistikler</h2>
        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-value">${reportData.summary.totalMonitors}</div>
                <div class="stat-label">Toplam Monitör</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">${reportData.summary.activeMonitors}</div>
                <div class="stat-label">Aktif Monitör</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">%${reportData.summary.avgUptime24h}</div>
                <div class="stat-label">Ortalama Uptime</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">${reportData.summary.avgResponseTime}ms</div>
                <div class="stat-label">Ortalama Yanıt</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">${reportData.summary.totalIncidents}</div>
                <div class="stat-label">Toplam Olay</div>
            </div>
        </div>
    </div>
    
    <h2 style="color: #007bff; font-size: 1.8rem; margin-bottom: 20px;">🖥️ Monitor Detayları</h2>
    <table class="monitor-table">
        <thead>
            <tr>
                <th>Monitor Adı</th>
                <th>Tip</th>
                <th>Durum</th>
                <th>24h Uptime</th>
                <th>7g Uptime</th>
                <th>30g Uptime</th>
                <th>Ort. Yanıt</th>
            </tr>
        </thead>
        <tbody>
            ${reportData.monitors.map(monitor => `
                <tr>
                    <td><strong>${monitor.name}</strong></td>
                    <td><span style="background: #e9ecef; padding: 4px 8px; border-radius: 12px; font-size: 0.8rem;">${monitor.type}</span></td>
                    <td><span class="${monitor.status === 1 ? 'status-active' : 'status-inactive'}">
                        ${monitor.status === 1 ? '✅ Aktif' : '❌ Pasif'}
                    </span></td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <span>%${monitor.uptime24h}</span>
                            <div class="uptime-bar" style="flex: 1;">
                                <div class="uptime-fill" style="width: ${monitor.uptime24h}%"></div>
                            </div>
                        </div>
                    </td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <span>%${monitor.uptime7d}</span>
                            <div class="uptime-bar" style="flex: 1;">
                                <div class="uptime-fill" style="width: ${monitor.uptime7d}%"></div>
                            </div>
                        </div>
                    </td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <span>%${monitor.uptime30d}</span>
                            <div class="uptime-bar" style="flex: 1;">
                                <div class="uptime-fill" style="width: ${monitor.uptime30d}%"></div>
                            </div>
                        </div>
                    </td>
                    <td><strong>${monitor.avgResponse}ms</strong></td>
                </tr>
            `).join('')}
        </tbody>
    </table>
    
    <h2 style="color: #007bff; font-size: 1.8rem; margin-bottom: 20px;">🏥 Sistem Sağlığı</h2>
    <div class="system-health">
        <div class="health-item overall">
            <div class="health-value">%${reportData.systemHealth.overall}</div>
            <div style="font-weight: 600; color: #333;">Genel Sağlık</div>
        </div>
        <div class="health-item performance">
            <div class="health-value">%${reportData.systemHealth.performance}</div>
            <div style="font-weight: 600; color: #333;">Performans</div>
        </div>
        <div class="health-item reliability">
            <div class="health-value">%${reportData.systemHealth.reliability}</div>
            <div style="font-weight: 600; color: #333;">Güvenilirlik</div>
        </div>
    </div>
    
    <div class="footer">
        <p>Bu rapor <span class="brand">BeyzTrack</span> monitoring sistemi tarafından otomatik olarak oluşturulmuştur.</p>
        <p>© ${new Date().getFullYear()} Beyz System. Tüm hakları saklıdır.</p>
    </div>
</body>
</html>`;
}

export function convertToCSV(data) {
    if (data.length === 0) return '';
    
    const headers = Object.keys(data[0]);
    const csvRows = [headers.join(',')];
    
    data.forEach(row => {
        const values = headers.map(header => {
            const value = row[header];
            return typeof value === 'string' ? `"${value}"` : value;
        });
        csvRows.push(values.join(','));
    });
    
    return csvRows.join('\n');
}

export function downloadFile(content, filename, mimeType) {
    const blob = new Blob([content], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
}
