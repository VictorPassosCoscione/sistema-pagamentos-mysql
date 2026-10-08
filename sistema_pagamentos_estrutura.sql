-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: sistema_pagamentos
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `cpf` char(11) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `status_cliente` enum('ATIVO','BLOQUEADO') NOT NULL DEFAULT 'ATIVO',
  `data_cadastro` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `cpf` (`cpf`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `emprestimos`
--

DROP TABLE IF EXISTS `emprestimos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emprestimos` (
  `id_emprestimo` int NOT NULL AUTO_INCREMENT,
  `id_solicitacao` int NOT NULL,
  `valor_aprovado` decimal(10,2) NOT NULL,
  `prazo_meses` int NOT NULL,
  `taxa_juros` decimal(5,2) NOT NULL,
  `valor_total` decimal(12,2) NOT NULL,
  `data_contratacao` date NOT NULL DEFAULT (curdate()),
  `status_emprestimo` enum('ATIVO','QUITADO','CANCELADO') NOT NULL DEFAULT 'ATIVO',
  PRIMARY KEY (`id_emprestimo`),
  UNIQUE KEY `id_solicitacao` (`id_solicitacao`),
  CONSTRAINT `fk_emprestimos_solicitacoes` FOREIGN KEY (`id_solicitacao`) REFERENCES `solicitacoes_credito` (`id_solicitacao`),
  CONSTRAINT `chk_emprestimo_prazo` CHECK ((`prazo_meses` > 0)),
  CONSTRAINT `chk_emprestimo_valor` CHECK ((`valor_aprovado` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pagamentos`
--

DROP TABLE IF EXISTS `pagamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pagamentos` (
  `id_pagamento` int NOT NULL AUTO_INCREMENT,
  `id_venda` int DEFAULT NULL,
  `id_parcela` int DEFAULT NULL,
  `valor_pago` decimal(10,2) NOT NULL,
  `data_pagamento` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `forma_pagamento` enum('DINHEIRO','PIX','CARTAO','TRANSFERENCIA') NOT NULL,
  `observacao` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_pagamento`),
  KEY `fk_pagamentos_vendas` (`id_venda`),
  KEY `fk_pagamentos_parcelas` (`id_parcela`),
  CONSTRAINT `fk_pagamentos_parcelas` FOREIGN KEY (`id_parcela`) REFERENCES `parcelas` (`id_parcela`),
  CONSTRAINT `fk_pagamentos_vendas` FOREIGN KEY (`id_venda`) REFERENCES `vendas` (`id_venda`),
  CONSTRAINT `chk_pagamento_origem` CHECK (((`id_venda` is not null) or (`id_parcela` is not null))),
  CONSTRAINT `chk_pagamento_valor` CHECK ((`valor_pago` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parcelas`
--

DROP TABLE IF EXISTS `parcelas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parcelas` (
  `id_parcela` int NOT NULL AUTO_INCREMENT,
  `id_venda` int NOT NULL,
  `numero_parcela` int NOT NULL,
  `valor_parcela` decimal(10,2) NOT NULL,
  `data_vencimento` date NOT NULL,
  `data_pagamento` date DEFAULT NULL,
  `status_parcela` enum('PENDENTE','PAGA','ATRASADA') NOT NULL DEFAULT 'PENDENTE',
  `valor_multa` decimal(10,2) NOT NULL DEFAULT '0.00',
  `dias_atraso` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_parcela`),
  UNIQUE KEY `id_venda` (`id_venda`,`numero_parcela`),
  CONSTRAINT `fk_parcelas_vendas` FOREIGN KEY (`id_venda`) REFERENCES `vendas` (`id_venda`),
  CONSTRAINT `chk_valor_parcela` CHECK ((`valor_parcela` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `solicitacoes_credito`
--

DROP TABLE IF EXISTS `solicitacoes_credito`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solicitacoes_credito` (
  `id_solicitacao` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int NOT NULL,
  `valor_solicitado` decimal(10,2) NOT NULL,
  `prazo_meses` int NOT NULL,
  `score` int NOT NULL,
  `taxa_juros` decimal(5,2) DEFAULT NULL,
  `status_solicitacao` enum('PENDENTE','APROVADA','RECUSADA') NOT NULL DEFAULT 'PENDENTE',
  `motivo_recusa` varchar(255) DEFAULT NULL,
  `data_solicitacao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_solicitacao`),
  KEY `fk_solicitacoes_clientes` (`id_cliente`),
  CONSTRAINT `fk_solicitacoes_clientes` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `chk_credito_prazo` CHECK ((`prazo_meses` > 0)),
  CONSTRAINT `chk_credito_score` CHECK ((`score` between 0 and 1000)),
  CONSTRAINT `chk_credito_valor` CHECK ((`valor_solicitado` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendas`
--

DROP TABLE IF EXISTS `vendas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendas` (
  `id_venda` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int NOT NULL,
  `tipo_venda` enum('A_VISTA','PARCELADA') NOT NULL,
  `valor_total` decimal(10,2) NOT NULL,
  `data_venda` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status_venda` enum('PENDENTE','PAGA','CANCELADA') NOT NULL DEFAULT 'PENDENTE',
  PRIMARY KEY (`id_venda`),
  KEY `fk_vendas_clientes` (`id_cliente`),
  CONSTRAINT `fk_vendas_clientes` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `chk_vendas_valor` CHECK ((`valor_total` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_validar_cliente_venda` BEFORE INSERT ON `vendas` FOR EACH ROW BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status_cliente
    INTO v_status
    FROM clientes
    WHERE id_cliente = NEW.id_cliente;

    IF v_status = 'BLOQUEADO' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Nao e permitido vender para cliente bloqueado.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `vw_parcelas_atrasadas`
--

DROP TABLE IF EXISTS `vw_parcelas_atrasadas`;
/*!50001 DROP VIEW IF EXISTS `vw_parcelas_atrasadas`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_parcelas_atrasadas` AS SELECT 
 1 AS `id_parcela`,
 1 AS `id_venda`,
 1 AS `id_cliente`,
 1 AS `nome_cliente`,
 1 AS `numero_parcela`,
 1 AS `valor_parcela`,
 1 AS `data_vencimento`,
 1 AS `dias_atraso`,
 1 AS `valor_multa`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_resumo_clientes`
--

DROP TABLE IF EXISTS `vw_resumo_clientes`;
/*!50001 DROP VIEW IF EXISTS `vw_resumo_clientes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_resumo_clientes` AS SELECT 
 1 AS `id_cliente`,
 1 AS `nome`,
 1 AS `status_cliente`,
 1 AS `quantidade_vendas`,
 1 AS `total_vendido`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'sistema_pagamentos'
--

--
-- Dumping routines for database 'sistema_pagamentos'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_analisar_credito` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_analisar_credito`(p_score INT, p_valor DECIMAL(10,2)) RETURNS varchar(20) CHARSET utf8mb4
    NO SQL
    DETERMINISTIC
BEGIN
    IF p_score >= 500 AND p_valor <= 50000 THEN
        RETURN 'APROVADO';
    ELSE
        RETURN 'RECUSADO';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_calcular_multa` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_calcular_multa`(
    p_valor DECIMAL(10,2),
    p_dias_atraso INT
) RETURNS decimal(12,2)
    NO SQL
    DETERMINISTIC
BEGIN
    IF p_valor <= 0 OR p_dias_atraso <= 0 THEN
        RETURN 0.00;
    END IF;

    RETURN ROUND(
        p_valor * (0.30 + (0.05 * p_dias_atraso)),
        2
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_taxa_juros` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_taxa_juros`(p_score INT) RETURNS decimal(5,2)
    NO SQL
    DETERMINISTIC
BEGIN
    DECLARE v_taxa DECIMAL(5,2);

    IF p_score >= 800 THEN
        SET v_taxa = 1.50;
    ELSEIF p_score >= 600 THEN
        SET v_taxa = 3.00;
    ELSEIF p_score >= 400 THEN
        SET v_taxa = 5.00;
    ELSE
        SET v_taxa = 8.00;
    END IF;

    RETURN v_taxa;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_analisar_solicitacao` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_analisar_solicitacao`(
    IN p_id_solicitacao INT
)
BEGIN
    DECLARE v_score INT;
    DECLARE v_valor DECIMAL(10,2);
    DECLARE v_prazo INT;
    DECLARE v_status VARCHAR(20);
    DECLARE v_taxa DECIMAL(5,2);
    DECLARE v_total DECIMAL(12,2);

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_status = NULL;

    SELECT score, valor_solicitado, prazo_meses, status_solicitacao
    INTO v_score, v_valor, v_prazo, v_status
    FROM solicitacoes_credito
    WHERE id_solicitacao = p_id_solicitacao;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solicitacao nao encontrada.';
    ELSEIF v_status <> 'PENDENTE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solicitacao nao esta pendente.';
    ELSEIF fn_analisar_credito(v_score, v_valor) = 'APROVADO' THEN
        SET v_taxa = fn_taxa_juros(v_score);
        SET v_total = ROUND(
            v_valor * (1 + (v_taxa / 100 * v_prazo)), 2
        );

        START TRANSACTION;

        UPDATE solicitacoes_credito
        SET status_solicitacao = 'APROVADA',
            taxa_juros = v_taxa,
            motivo_recusa = NULL
        WHERE id_solicitacao = p_id_solicitacao;

        INSERT INTO emprestimos (
            id_solicitacao, valor_aprovado,
            prazo_meses, taxa_juros, valor_total
        )
        VALUES (
            p_id_solicitacao, v_valor,
            v_prazo, v_taxa, v_total
        );

        COMMIT;
    ELSE
        UPDATE solicitacoes_credito
        SET status_solicitacao = 'RECUSADA',
            taxa_juros = fn_taxa_juros(v_score),
            motivo_recusa =
                'Score abaixo do minimo ou valor acima do limite.'
        WHERE id_solicitacao = p_id_solicitacao;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_atualizar_atrasos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_atualizar_atrasos`()
BEGIN
    UPDATE parcelas
    SET dias_atraso = GREATEST(
        DATEDIFF(CURRENT_DATE, data_vencimento), 0
    ),
    valor_multa = fn_calcular_multa(
        valor_parcela,
        DATEDIFF(CURRENT_DATE, data_vencimento)
    ),
    status_parcela = CASE
        WHEN data_vencimento < CURRENT_DATE THEN 'ATRASADA'
        ELSE 'PENDENTE'
    END
    WHERE status_parcela IN ('PENDENTE', 'ATRASADA');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_baixar_pagamento` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_baixar_pagamento`(
    IN p_id_parcela INT,
    IN p_valor_pago DECIMAL(10,2),
    IN p_forma_pagamento VARCHAR(20)
)
BEGIN
    DECLARE v_id_venda INT;
    DECLARE v_valor_parcela DECIMAL(10,2);
    DECLARE v_status VARCHAR(20);
    DECLARE v_encontrada INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_encontrada = 0;

    SELECT id_venda, valor_parcela, status_parcela
    INTO v_id_venda, v_valor_parcela, v_status
    FROM parcelas
    WHERE id_parcela = p_id_parcela;

    IF v_encontrada = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Parcela nao encontrada.';
    ELSEIF p_valor_pago IS NULL OR p_valor_pago <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Valor de pagamento invalido.';
    ELSEIF v_status = 'PAGA' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Esta parcela ja foi paga.';
    ELSEIF p_valor_pago < v_valor_parcela THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pagamento inferior ao valor da parcela.';
    ELSE
        START TRANSACTION;

        INSERT INTO pagamentos (
            id_venda, id_parcela, valor_pago, forma_pagamento
        )
        VALUES (
            v_id_venda, p_id_parcela, p_valor_pago, p_forma_pagamento
        );

        UPDATE parcelas
        SET status_parcela = 'PAGA',
            data_pagamento = CURRENT_DATE
        WHERE id_parcela = p_id_parcela;

        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_parcelas_atrasadas`
--

/*!50001 DROP VIEW IF EXISTS `vw_parcelas_atrasadas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_parcelas_atrasadas` AS select `p`.`id_parcela` AS `id_parcela`,`p`.`id_venda` AS `id_venda`,`c`.`id_cliente` AS `id_cliente`,`c`.`nome` AS `nome_cliente`,`p`.`numero_parcela` AS `numero_parcela`,`p`.`valor_parcela` AS `valor_parcela`,`p`.`data_vencimento` AS `data_vencimento`,(to_days(curdate()) - to_days(`p`.`data_vencimento`)) AS `dias_atraso`,`fn_calcular_multa`(`p`.`valor_parcela`,(to_days(curdate()) - to_days(`p`.`data_vencimento`))) AS `valor_multa` from ((`parcelas` `p` join `vendas` `v` on((`p`.`id_venda` = `v`.`id_venda`))) join `clientes` `c` on((`v`.`id_cliente` = `c`.`id_cliente`))) where (`p`.`status_parcela` = 'ATRASADA') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_resumo_clientes`
--

/*!50001 DROP VIEW IF EXISTS `vw_resumo_clientes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_resumo_clientes` AS select `c`.`id_cliente` AS `id_cliente`,`c`.`nome` AS `nome`,`c`.`status_cliente` AS `status_cliente`,count(distinct `v`.`id_venda`) AS `quantidade_vendas`,coalesce(sum(`v`.`valor_total`),0) AS `total_vendido` from (`clientes` `c` left join `vendas` `v` on((`c`.`id_cliente` = `v`.`id_cliente`))) group by `c`.`id_cliente`,`c`.`nome`,`c`.`status_cliente` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-08 18:36:57
