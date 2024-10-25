from setuptools import setup

APP = ['code/main.py']
DATA_FILES = ['graphics/*', 'audio/*', 'fonts/*']
OPTIONS = {
    'argv_emulation': True,
    'packages': ['pygame', 'numpy', 'Cython'],
    'excludes': ['PyInstaller', 'PySide2', 'distutils.util'],  # Explicitly exclude these packages
}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)