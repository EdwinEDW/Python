import pyodbc
import pandas as pd
import matplotlib.pyplot as plt

# 1. Configuración de la conexión a SQL Server
conn_str = (
    r'DRIVER={SQL Server};'
    r'SERVER=Yoyito\SQLEXPRESS;'
    r'DATABASE=EXAMENANALISTAJR;'
    r'Trusted_Connection=yes;'
)
# Al estar dentro de paréntesis sin comas, Python las une automáticamente.

try:
    # 2. Conectar y extraer los datos
    with pyodbc.connect(conn_str) as conn:
        query = "SELECT Categoria, Gasto_Total FROM Datos_Grafica_Pastel"
        df = pd.read_sql(query, conn)

    # 3. Configuración de la Gráfica de Pastel
    plt.figure(figsize=(10, 7))
    colores = ['#ff9999','#66b3ff','#99ff99'] # Colores estéticos
    
    plt.pie(
        df['Gasto_Total'], 
        labels=df['Categoria'], 
        autopct='%1.1f%%', # Muestra el porcentaje con un decimal
        startangle=140, 
        colors=colores,
        explode=(0.05, 0, 0), # Resalta la categoría principal (Medicamentos)
        shadow=True
    )

    plt.title('Distribución Nacional de Demanda por Tipo de Insumo', fontsize=14)
    plt.axis('equal') # Asegura que el pastel sea un círculo
    
    # 4. Mostrar y guardar
    plt.show()
    # plt.savefig('grafica_pastel_insumos.png') # Opcional: guardar como imagen

except Exception as e:
    print(f"Error al conectar o graficar: {e}")