"""Build source ZIP, .love and Windows portable ZIP with an installed LÖVE runtime."""
from pathlib import Path
import argparse, json, hashlib, zipfile

root=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--runtime',default=r'C:\Program Files\LOVE')
args=parser.parse_args()
runtime=Path(args.runtime)
dist=root/'dist';dist.mkdir(exist_ok=True)
game_files=[root/name for name in ['main.lua','conf.lua','config.lua']]
for directory in ['src','data','assets','tests']:
    game_files.extend(p for p in (root/directory).rglob('*') if p.is_file())
game_files+= [root/'README.md',root/'docs/REFERENCIAS.md',root/'docs/VALIDACAO.md',
              root/'docs/TEST-RESULTS.txt',root/'docs/preview.png']
game_files=sorted(game_files)
love_path=dist/'GLA-Boss-Fight-Simulator.love'
with zipfile.ZipFile(love_path,'w',zipfile.ZIP_DEFLATED) as z:
    for name in ['player','bosses','effects','tiles']: z.writestr('assets/'+name+'/',b'')
    for path in game_files: z.write(path,path.relative_to(root).as_posix())

source_path=dist/'GLA-Boss-Fight-Simulator-Source.zip'
source_files=game_files+[root/'tools/package.py',root/'docs/original-main.lua',root/'.gitignore']
with zipfile.ZipFile(source_path,'w',zipfile.ZIP_DEFLATED) as z:
    for name in ['player','bosses','effects','tiles']: z.writestr('gla-boss-simulator/assets/'+name+'/',b'')
    for path in source_files: z.write(path,'gla-boss-simulator/'+path.relative_to(root).as_posix())

exe=runtime/'love.exe'
if not exe.is_file(): raise SystemExit('LÖVE runtime not found: '+str(runtime))
portable=dist/'GLA-Boss-Fight-Simulator-Windows.zip'
with zipfile.ZipFile(portable,'w',zipfile.ZIP_DEFLATED) as z:
    prefix='GLA-Boss-Fight-Simulator/'
    z.writestr(prefix+'GLA Boss Fight Simulator.exe',exe.read_bytes()+love_path.read_bytes())
    for dll in sorted(runtime.glob('*.dll')): z.write(dll,prefix+dll.name)
    # Runtime redistribution includes the bundled licenses for LÖVE and dependencies.
    z.write(runtime/'license.txt',prefix+'LOVE-license.txt')
    z.write(root/'README.md',prefix+'README.md')
    z.write(root/'docs/REFERENCIAS.md',prefix+'docs/REFERENCIAS.md')
    z.write(root/'docs/VALIDACAO.md',prefix+'docs/VALIDACAO.md')
    z.write(root/'docs/TEST-RESULTS.txt',prefix+'docs/TEST-RESULTS.txt')
    z.write(root/'docs/preview.png',prefix+'docs/preview.png')

manifest={}
for artifact in [love_path,source_path,portable]:
    with zipfile.ZipFile(artifact) as z: assert z.testzip() is None
    manifest[artifact.name]={'bytes':artifact.stat().st_size,'sha256':hashlib.sha256(artifact.read_bytes()).hexdigest()}
(dist/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(json.dumps(manifest,indent=2))
