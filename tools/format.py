"""Formata os módulos Lua com o padrão do projeto; não é necessário para jogar."""
import argparse
from pathlib import Path
import shutil
import subprocess

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--check', action='store_true', help='Verifica sem modificar os arquivos')
parser.add_argument('--stylua', help='Caminho opcional para o executável StyLua')
args = parser.parse_args()

local_formatter = root / '.tools/stylua/stylua.exe'
formatter = args.stylua or (str(local_formatter) if local_formatter.is_file() else shutil.which('stylua'))
if not formatter:
    raise SystemExit('Instale StyLua ou informe --stylua CAMINHO. Veja docs/EDITANDO-O-JOGO.md.')

command = [formatter, '--verify']
if args.check:
    command.append('--check')
command.extend([
    'main.lua', 'conf.lua', 'config.lua', 'src', 'data', 'tests',
    'assets/player/manifest.lua', 'assets/bosses/manifest.lua',
])
raise SystemExit(subprocess.run(command, cwd=root).returncode)
