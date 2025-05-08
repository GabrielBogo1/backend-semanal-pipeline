package com.api.product.product_api.entity;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter @Setter
@Table
@AllArgsConstructor
@NoArgsConstructor
public class Product {

    @Id
    @Column(name = "id", nullable = false, unique = true)
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column (name = "nome_produto", nullable = false)
    private String productName;

    @Column(name = "observacao_produto")
    private String productObservation;

//    @Column(name = "preco_produto", nullable = false)
//    private Double price;
//
//    @Column(name = "imagem_produto")
//    private String imageUrl;
}