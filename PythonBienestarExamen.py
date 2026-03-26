import pandas as pd
import glob
import os
from sqlalchemy import create_engine
import urllib
server = r'Yoyito\SQLEXPRESS' 
database = 'EXAMENANALISTAJR'
params = urllib.parse.quote_plus(f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes;')
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")
ruta_carpetas = r'C:\Users\yosel\OneDrive\Escritorio\Examen\prueba'
archivos = glob.glob(os.path.join(ruta_carpetas, "**", "*.xls*"), recursive=True)
columnas_validas = [
    'entidad', 'clues', 'cpm', 'grupo', 'clave_cnis', 
    'clave_kit_nucleos', 'clave_kit_movil', 'clave_kit_cessa', 
    'clave_kit_hospital', 'clave_kit_hospital_basico_comunitario', 
    'clave_kit_hospital_ped', 'clave_kit_hospital_materno', 
    'clave_kit_hospital_psiquiatrico', 'clave_kit_uneme_pn'
]
print(f"Iniciando carga de {len(archivos)} archivos...\n")
for f in archivos:
    try:
        df = pd.read_excel(f, sheet_name=0)
        nombre_archivo = os.path.basename(f)
        columnas_originales = list(df.columns)
        df.columns = [str(c).lower().strip() for c in df.columns]
        mapeo = {'demanda': 'cpm', 'unidad': 'clues', 'entidad_federativa': 'entidad'}
        df = df.rename(columns=mapeo)
        tiene_unnamed = any('unnamed' in str(c).lower() for c in columnas_originales)
        fue_modificado = any(col in ['demanda', 'unidad', 'entidad_federativa'] for col in [str(c).lower().strip() for c in columnas_originales])
        
        if tiene_unnamed or fue_modificado:
            print(f"⚠️  Aviso en {nombre_archivo}: Se detectaron y limpiaron columnas no válidas o nombres incorrectos.")
        cols_a_enviar = [c for c in columnas_validas if c in df.columns]
        df_limpio = df[cols_a_enviar].copy() 
      
        df_limpio['archivo_origen'] = nombre_archivo
       
        df_limpio.to_sql('DATAFRAMEBIENESTAR', schema='dbo', con=engine, if_exists='append', index=False)
        print(f"✅ Cargado: {nombre_archivo}")
    except Exception as e:
        print(f"❌ ERROR CRÍTICO en {os.path.basename(f)}: {e}")

print("\n--- PROCESO FINALIZADO: Todos los datos válidos están en SQL Server ---")