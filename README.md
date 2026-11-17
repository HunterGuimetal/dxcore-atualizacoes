# DXCORE · atualizações

Arquivos que os computadores com o DXCORE instalado baixam para se atualizar.
Versão atual: **10.44** (2026-11-06)

- Simulação de dobra: o desenho enquadra a peça inteira em todos os passos (peça larga pendurada abaixo da matriz não fica mais minúscula).
- Simulação de dobra também em peça com dobras atravessadas (orelhas das pontas): simula o perfil das dobras principais e avisa que as orelhas são dobradas antes, com a peça ainda plana.
- Importar DWG/DXF no Gerador: reconhece a linha de dobra tracejada que para na orelha (não vai de borda a borda), junta a dobra desenhada em pedaços entre os rasgos e a dobra curta da orelha (vale só na largura dela); o lado que dobra é sempre o de fora. Peça 114 Suporte Cartões: 8 dobras.
- Reaproveitamento de peça grande (mais de 8% da chapa): testa a peça girada de 3 em 3°, alinhada pelos próprios lados e o par girado 180° grau a grau; a 2ª peça também entra pela direita deslizando até encostar no contorno da 1ª; e a 1ª só é posta onde ainda cabe outra (olha uma peça à frente). Trapézio grande que cabe 2 na chapa: de 12 para 6 chapas. Bateria de 13 casos: nenhum piorou.
- Orçamento: o resumo à direita (total, chapas e visualização 2D) tem rolagem própria — dá para descer até as chapas sem rolar a lista de peças até o fim.
- Parâmetros e preços › + Adicionar material: nome, preço por kg, densidade, espessura máxima e 'corta como' (copia a tabela de velocidade de corte e o gás de um material parecido, que dá para ajustar depois). O material novo aparece nos orçamentos, no estoque de chapas e no Limpar; o ✕ tira da lista.

O arquivo do programa é cifrado e a atualização é assinada. Não edite estes arquivos à mão.
