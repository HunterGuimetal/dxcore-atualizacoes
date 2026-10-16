# DXCORE by GUIMETAL · atualizações

Arquivos que os computadores da GUIMETAL baixam para atualizar o DXCORE.
Versão atual: **8.75** (2026-10-16)

- Gerador · arquivo com várias peças (PDF, DXF, DWG, montagem STEP ou Parasolid) vira um projeto com uma peça para cada, com nome, código e quantidade de cada uma, para o técnico conferir e editar uma por uma.
- Ordem de serviço · a OS impressa mostra o desenho de cada peça, igual à proposta em PDF (também nas OS já criadas a partir de orçamento e nas de DXF do projeto).
- Gerador · modelo novo Flange com orelhas (junta de escapamento): corpo redondo, furo central, orelhas com furo e raio de concordância; distância e ângulo de cada orelha podem ser diferentes.
- Limpar · PDF, DXF ou DWG com várias peças na mesma folha: cada peça vira um item da lista (1/3, 2/3…), como as peças de uma montagem no SolidWorks. As vistas da mesma peça e as tabelas continuam fora.
- Limpar · o texto de cada peça (POS. 02 - ORELHA - QTD: 4) vira descrição, quantidade e código do item; peças iguais repetidas viram um item só com a quantidade.
- Gerador · STEP de chapa feito com canto vivo (sem raio na dobra) agora abre com todas as abas e furos: antes vinha só a face de baixo. Planifica com raio interno = espessura.
- Gerador · peça importada com dobra abre dobrada e de pé, com a maior face no chão, como no modelo do cliente.
- Gerador · furos e rasgos de STEP e Parasolid chegam como círculos e arcos de verdade (22 entidades em vez de 872), prontos para cota e edição.
- Tubos · Barras (Auto Nest): todas as peças nas barras com zona morta, margem, espaço, retalhos primeiro e corte comum; aproveitamento, sobra, tempo de máquina e lista em CSV.
- Tubos · Simular (F5): o laser percorre pontas, furos e gravação na ordem, com o relógio do tempo de máquina.
- Tubos · Gravação no tubo (Add Text), furo passante, furos ao redor do tubo (matriz) e lista do Excel (colar as linhas e virar tubos). Tempo de máquina por peça no resultado.
- Tubos · Mouse e teclas como no TubesT da máquina: roda apertada gira, Ctrl + roda apertada move, Shift/Ctrl + roda giram o tubo, F3 enquadra, F4 vista padrão, duplo clique abre as vistas, Esc, Delete, Ctrl+C/Ctrl+V. F1 mostra os atalhos.
- Tubos · Nomes e barra como no TubesT: comprimento do tubo, zona morta, margem da frente e espaço entre peças (editáveis).
- Tubos · Exportar: IGES (para o TubesT/TubePro da máquina) e STEP (SolidWorks/cliente) com o sólido exato, tubo deitado no eixo X, em mm: pontas, bocas de lobo, linguetas e furos com as superfícies de verdade.
- Tubos · Conjunto inteiro em .zip: cada tubo em IGES e STEP para cortar, mais o conjunto montado em STEP.
- Tubos · Rasgo e lingueta: no encaixe, a ponta ganha 2 ou 4 linguetas e os rasgos saem sozinhos no outro tubo, exatamente onde elas entram (com folga). Entram no corte e no orçamento e acompanham as mudanças.
- Tubos · Vista explodida (tecla E): afasta na tela os tubos encaixados para ver linguetas e rasgos.
- Tubos · Montagem: vários tubos no mesmo conjunto, cada um com posição e direção. Ramal: clique num tubo e sai outro dali, já encaixado.
- Tubos · Encaixe automático: a ponta que encosta noutro tubo ganha a boca de lobo exata (qualquer ângulo, fora do centro) ou o corte plano na face do tubo quadrado; no canto, esquadria pela metade do ângulo. O comprimento se ajusta sozinho e acompanha as mudanças.
- Tubos · Lista de corte do conjunto com peso total e barras por perfil; Orçar o conjunto manda todos os tubos para a Calculadora de uma vez.
- Proposta em PDF: nova aba Perdidos, com a data e o motivo da perda de cada orçamento. O botão Resgatar volta o orçamento para Enviado (entra de novo em Para cobrar) para tentar outra vez com o cliente.
- Nova ferramenta TUBOS (no início, em Produção): o tubo deitado em 3D com o material de verdade. Redondo, quadrado, retangular, oblongo e barra redonda.
- Tubos · Pontas: reta, em ângulo (meia-esquadria) e boca de lobo para soldar em tubo redondo, com o Ø do outro tubo, atravessado ou em pé, o ângulo entre eles e fora do centro.
- Tubos · Furos, roscas (pré-furo), oblongos e recortes: clique no tubo onde quer (ou na parede desenrolada), em qualquer face; repetir em fila com passo; setas movem.
- Tubos · Rosca externa na ponta do tubo redondo ou da barra, para porca (métrica ou gás/BSP), com chanfro de 45°.
- Tubos · Parede desenrolada, peso, kg/m, corte exato, perfurações e quantas peças cabem na barra. Orçar tubo manda tudo exato para a Calculadora; Salvar e Abrir na pasta de dados.
- Tubos · Importar STEP/IGES de tubo: perfil, pontas (reta, ângulo, boca de lobo) e furos viram tubo editável. O Gerador de peças ficou só para chapa e manda os tubos para cá.

O arquivo do programa é cifrado e a atualização é assinada. Não edite estes arquivos à mão.
