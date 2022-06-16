import subprocess
import sys
from os import path
from setuptools import setup, find_packages

__version__ = '0.1'


# Install packages from pip ==============================================================
def install_with_pip(pack, vers=None):

    # sys.executable gives the path to the python interpreter
    if vers is None:
        print("** AnalysisXCD: Installing {}".format(pack))
        subprocess.call([sys.executable, "-m", "pip", "install", "{0}".format(pack)])
    else:
        print("** AnalysisXCD: Installing {}=={}".format(pack, vers))
        subprocess.call([sys.executable, "-m", "pip", "install", "{0}=={1}".format(pack, vers)])


# Main setup
if __name__ == '__main__':
    print(sys.path)

    # Install requirements ===================================
    with open('requirements.txt') as f:
        required = f.read().splitlines()
    for ipack in required:
        try:
            pkg, version = ipack.split(">=")[0:2]
            if pkg[0] == "#":
                continue
            install_with_pip(pkg, version)
        except ValueError:
            pkg = ipack
            if pkg[0] == "#":
                continue
            install_with_pip(pkg)

    this_directory = path.abspath(path.dirname(__file__))
    with open(path.join(this_directory, 'README.md'), encoding='utf-8') as f:
        long_description = f.read()

    # Setup AnalysisXCD ===========================================
    setup(
        name='AnalysisXCD',
        version=__version__,
        description='Python program to anlayze XCD files produced by Materials Studio.',
        long_description=long_description,
        long_description_content_type='text/markdown',
        license="MIT",
        scripts=['./analysis_xcd/analysisxcd.py'],
        author="Javier Ramos",
        author_email="jrdcasa@gmail.com",
        classifiers=[
            'Development Status :: 5 - Production/Stable',
            'Intended Audience :: Education',
            'Intended Audience :: Science/Research',
            'License :: OSI Approved :: MIT License',
            'Operating System :: OS Independent',
            'Programming Language :: Python',
            'Topic :: Scientific/Engineering'
        ],
        # This automatically detects the packages in the specified
        # (or current directory if no directory is given).
        packages=find_packages(exclude=['test', 'docs', 'data']),
    )
