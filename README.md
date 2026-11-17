# DXCORE · atualizações

Arquivos que os computadores com o DXCORE instalado baixam para se atualizar.
Versão atual: **10.46** (2026-11-06)

- Vídeo da peça novo, no visual do Projetista: fundo escuro com grade, corte a laser (cabeçote com feixe e faíscas percorrendo furos e contorno, corte acendendo em laranja), linhas de dobra acendendo em neon com a dobradeira contando as dobras, a peça dobrando e girando 360° com cotas em neon (comprimento, largura e altura). 60 fps, ~15 s.
- Vídeo da peça: peça pesada (muitos furos e dobras) não trava mais o programa — a dobra é preparada em etapas com o andamento na barra de baixo, as etapas do meio saem sem o arredondado das quinas (só a peça pronta tem) e a peça dobrada não é mais calculada duas vezes.
- Simulação de dobra: o desenho enquadra a peça inteira em todos os passos (peça larga pendurada abaixo da matriz não fica mais minúscula).
- Simulação de dobra também em peça com dobras atravessadas (orelhas das pontas): simula o perfil das dobras principais e avisa que as orelhas são dobradas antes, com a peça ainda plana.
- Importar DWG/DXF no Gerador: reconhece a linha de dobra tracejada que para na orelha (não vai de borda a borda), junta a dobra desenhada em pedaços entre os rasgos e a dobra curta da orelha (vale só na largura dela); o lado que dobra é sempre o de fora. Peça 114 Suporte Cartões: 8 dobras.
- Reaproveitamento de peça grande (mais de 8% da chapa): testa a peça girada de 3 em 3°, alinhada pelos próprios lados e o par girado 180° grau a grau; a 2ª peça também entra pela direita deslizando até encostar no contorno da 1ª; e a 1ª só é posta onde ainda cabe outra (olha uma peça à frente). Trapézio grande que cabe 2 na chapa: de 12 para 6 chapas. Bateria de 13 casos: nenhum piorou.

O arquivo do programa é cifrado e a atualização é assinada. Não edite estes arquivos à mão.
