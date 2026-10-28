# DXCORE · atualizações

Arquivos que os computadores com o DXCORE instalado baixam para se atualizar.
Versão atual: **9.29** (2026-10-28)

- Velocidade · o DXCORE estava relendo, pela rede, um a um, os registros de alterações de todos os computadores (127 arquivos) a cada tela aberta. Agora apaga os registros antigos que o resumo já cobre e só relê o que mudou. Na primeira abertura ele faz essa faxina; depois cada tela pede até 5 vezes menos à pasta da rede.
- Servidor local · passa a informar o tamanho e a data de cada arquivo, para o DXCORE não baixar o que não mudou (vale depois que o computador for reiniciado).

O arquivo do programa é cifrado e a atualização é assinada. Não edite estes arquivos à mão.
