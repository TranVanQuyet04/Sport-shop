--
-- PostgreSQL database dump
--

\restrict NbdgMZE92MgSutAGTBCIalsG4Dmek8GLzejCAKeerLGeb0xbCik9Wdg7zl2xoR1

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-06-16 16:15:19

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 17227)
-- Name: brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.brands (
    id bigint NOT NULL,
    banner character varying(1000),
    brand_name character varying(255),
    created_at timestamp(6) without time zone,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    logo character varying(1000),
    slug character varying(255) NOT NULL,
    updated_at timestamp(6) without time zone
);


ALTER TABLE public.brands OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 17226)
-- Name: brands_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.brands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.brands_id_seq OWNER TO postgres;

--
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 217
-- Name: brands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.brands_id_seq OWNED BY public.brands.id;


--
-- TOC entry 220 (class 1259 OID 17237)
-- Name: cart_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_items (
    id bigint NOT NULL,
    quantity integer,
    cart_id bigint,
    variant_id bigint
);


ALTER TABLE public.cart_items OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17236)
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_items_id_seq OWNER TO postgres;

--
-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 219
-- Name: cart_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_items_id_seq OWNED BY public.cart_items.id;


--
-- TOC entry 222 (class 1259 OID 17244)
-- Name: carts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carts (
    id bigint NOT NULL,
    user_id bigint
);


ALTER TABLE public.carts OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17243)
-- Name: carts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.carts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.carts_id_seq OWNER TO postgres;

--
-- TOC entry 5139 (class 0 OID 0)
-- Dependencies: 221
-- Name: carts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.carts_id_seq OWNED BY public.carts.id;


--
-- TOC entry 224 (class 1259 OID 17251)
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    category_name character varying(255) NOT NULL,
    description character varying(255),
    parent_id bigint
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17250)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO postgres;

--
-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 223
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- TOC entry 226 (class 1259 OID 17260)
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id bigint NOT NULL,
    content text,
    file_url character varying(255),
    sender character varying(255),
    sent_at timestamp(6) without time zone,
    type character varying(255),
    room_id bigint
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17259)
-- Name: chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_messages_id_seq OWNER TO postgres;

--
-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 225
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_messages_id_seq OWNED BY public.chat_messages.id;


--
-- TOC entry 228 (class 1259 OID 17269)
-- Name: chat_rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_rooms (
    id bigint NOT NULL,
    admin_name character varying(255),
    customer_name character varying(255),
    has_unread boolean,
    last_message_at timestamp(6) without time zone,
    type character varying(255),
    CONSTRAINT chat_rooms_type_check CHECK (((type)::text = ANY ((ARRAY['ADMIN_SUPPORT'::character varying, 'AI_SUPPORT'::character varying])::text[])))
);


ALTER TABLE public.chat_rooms OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17268)
-- Name: chat_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_rooms_id_seq OWNER TO postgres;

--
-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 227
-- Name: chat_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_rooms_id_seq OWNED BY public.chat_rooms.id;


--
-- TOC entry 230 (class 1259 OID 17279)
-- Name: collection_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collection_products (
    id bigint NOT NULL,
    sort_order integer,
    collection_id bigint,
    variant_id bigint
);


ALTER TABLE public.collection_products OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17278)
-- Name: collection_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collection_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collection_products_id_seq OWNER TO postgres;

--
-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 229
-- Name: collection_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collection_products_id_seq OWNED BY public.collection_products.id;


--
-- TOC entry 232 (class 1259 OID 17286)
-- Name: collections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collections (
    id bigint NOT NULL,
    description character varying(255),
    end_date date,
    image_url character varying(255),
    is_active boolean,
    name character varying(255),
    slug character varying(255),
    start_date date,
    type character varying(255)
);


ALTER TABLE public.collections OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 17285)
-- Name: collections_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collections_id_seq OWNER TO postgres;

--
-- TOC entry 5144 (class 0 OID 0)
-- Dependencies: 231
-- Name: collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collections_id_seq OWNED BY public.collections.id;


--
-- TOC entry 234 (class 1259 OID 17295)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id bigint NOT NULL,
    price numeric(38,2),
    quantity integer,
    order_id bigint,
    variant_id bigint
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17294)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO postgres;

--
-- TOC entry 5145 (class 0 OID 0)
-- Dependencies: 233
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- TOC entry 236 (class 1259 OID 17302)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id bigint NOT NULL,
    note character varying(255),
    order_date timestamp(6) without time zone,
    payment_method character varying(255),
    phone_number character varying(255),
    recipient_name character varying(255),
    shipping_address character varying(255),
    status character varying(255),
    total_amount numeric(38,2),
    user_id bigint,
    CONSTRAINT orders_payment_method_check CHECK (((payment_method)::text = ANY ((ARRAY['COD'::character varying, 'VNPAY'::character varying, 'MOMO'::character varying])::text[]))),
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'CONFIRMED'::character varying, 'PACKING'::character varying, 'SHIPPED'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying, 'PAID'::character varying, 'DELIVERED'::character varying, 'SHIPPING'::character varying])::text[])))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 17301)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- TOC entry 5146 (class 0 OID 0)
-- Dependencies: 235
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 238 (class 1259 OID 17313)
-- Name: password_reset_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_token (
    id bigint NOT NULL,
    created_date timestamp(6) without time zone NOT NULL,
    expiry_date timestamp(6) without time zone NOT NULL,
    token character varying(255) NOT NULL,
    used boolean,
    user_id bigint NOT NULL
);


ALTER TABLE public.password_reset_token OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 17312)
-- Name: password_reset_token_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.password_reset_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.password_reset_token_id_seq OWNER TO postgres;

--
-- TOC entry 5147 (class 0 OID 0)
-- Dependencies: 237
-- Name: password_reset_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.password_reset_token_id_seq OWNED BY public.password_reset_token.id;


--
-- TOC entry 240 (class 1259 OID 17320)
-- Name: product_images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_images (
    id bigint NOT NULL,
    image_url character varying(255) NOT NULL,
    is_primary boolean,
    variant_id bigint NOT NULL
);


ALTER TABLE public.product_images OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 17319)
-- Name: product_images_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_images_id_seq OWNER TO postgres;

--
-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 239
-- Name: product_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_images_id_seq OWNED BY public.product_images.id;


--
-- TOC entry 256 (class 1259 OID 17508)
-- Name: product_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_reviews (
    id bigint NOT NULL,
    comment text,
    created_at timestamp(6) without time zone,
    rating integer NOT NULL,
    order_item_id bigint,
    product_id bigint,
    user_id bigint
);


ALTER TABLE public.product_reviews OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 17507)
-- Name: product_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_reviews_id_seq OWNER TO postgres;

--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 255
-- Name: product_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_reviews_id_seq OWNED BY public.product_reviews.id;


--
-- TOC entry 242 (class 1259 OID 17327)
-- Name: product_variants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variants (
    id bigint NOT NULL,
    color character varying(255),
    price numeric(38,2),
    size character varying(255),
    sku character varying(255),
    stock_quantity integer,
    product_id bigint,
    version bigint
);


ALTER TABLE public.product_variants OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 17326)
-- Name: product_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_variants_id_seq OWNER TO postgres;

--
-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 241
-- Name: product_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_variants_id_seq OWNED BY public.product_variants.id;


--
-- TOC entry 244 (class 1259 OID 17336)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    description text,
    product_name character varying(255) NOT NULL,
    brand_id bigint,
    category_id bigint,
    sport_id bigint,
    average_rating double precision,
    is_active boolean
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 17335)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- TOC entry 5151 (class 0 OID 0)
-- Dependencies: 243
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- TOC entry 246 (class 1259 OID 17345)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    role_id bigint NOT NULL,
    role_code character varying(255) NOT NULL,
    role_description character varying(255),
    role_name character varying(255) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 17344)
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_role_id_seq OWNER TO postgres;

--
-- TOC entry 5152 (class 0 OID 0)
-- Dependencies: 245
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_role_id_seq OWNED BY public.roles.role_id;


--
-- TOC entry 248 (class 1259 OID 17354)
-- Name: sports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sports (
    id bigint NOT NULL,
    description character varying(255),
    sport_name character varying(255) NOT NULL
);


ALTER TABLE public.sports OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 17353)
-- Name: sports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sports_id_seq OWNER TO postgres;

--
-- TOC entry 5153 (class 0 OID 0)
-- Dependencies: 247
-- Name: sports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sports_id_seq OWNED BY public.sports.id;


--
-- TOC entry 250 (class 1259 OID 17363)
-- Name: user_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_addresses (
    id bigint NOT NULL,
    city character varying(255) NOT NULL,
    district character varying(255) NOT NULL,
    is_default boolean,
    phone_number character varying(255) NOT NULL,
    recipient_name character varying(255) NOT NULL,
    street character varying(255) NOT NULL,
    ward character varying(255) NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.user_addresses OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 17362)
-- Name: user_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_addresses_id_seq OWNER TO postgres;

--
-- TOC entry 5154 (class 0 OID 0)
-- Dependencies: 249
-- Name: user_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_addresses_id_seq OWNED BY public.user_addresses.id;


--
-- TOC entry 252 (class 1259 OID 17372)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone,
    email character varying(255) NOT NULL,
    failed_login_attempts integer,
    full_name character varying(255) NOT NULL,
    last_login_date timestamp(6) without time zone,
    last_password_change_date timestamp(6) without time zone,
    lock_time timestamp(6) without time zone,
    password character varying(255) NOT NULL,
    phone_number character varying(255) NOT NULL,
    status boolean NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 17371)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5155 (class 0 OID 0)
-- Dependencies: 251
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 254 (class 1259 OID 17381)
-- Name: valid_refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.valid_refresh_tokens (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    expired_time timestamp(6) without time zone NOT NULL,
    jwt_id character varying(255) NOT NULL,
    revoked boolean NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.valid_refresh_tokens OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 17380)
-- Name: valid_refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.valid_refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.valid_refresh_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 5156 (class 0 OID 0)
-- Dependencies: 253
-- Name: valid_refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.valid_refresh_tokens_id_seq OWNED BY public.valid_refresh_tokens.id;


--
-- TOC entry 4837 (class 2604 OID 17230)
-- Name: brands id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands ALTER COLUMN id SET DEFAULT nextval('public.brands_id_seq'::regclass);


--
-- TOC entry 4839 (class 2604 OID 17240)
-- Name: cart_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN id SET DEFAULT nextval('public.cart_items_id_seq'::regclass);


--
-- TOC entry 4840 (class 2604 OID 17247)
-- Name: carts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts ALTER COLUMN id SET DEFAULT nextval('public.carts_id_seq'::regclass);


--
-- TOC entry 4841 (class 2604 OID 17254)
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- TOC entry 4842 (class 2604 OID 17263)
-- Name: chat_messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages ALTER COLUMN id SET DEFAULT nextval('public.chat_messages_id_seq'::regclass);


--
-- TOC entry 4843 (class 2604 OID 17272)
-- Name: chat_rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_rooms ALTER COLUMN id SET DEFAULT nextval('public.chat_rooms_id_seq'::regclass);


--
-- TOC entry 4844 (class 2604 OID 17282)
-- Name: collection_products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_products ALTER COLUMN id SET DEFAULT nextval('public.collection_products_id_seq'::regclass);


--
-- TOC entry 4845 (class 2604 OID 17289)
-- Name: collections id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections ALTER COLUMN id SET DEFAULT nextval('public.collections_id_seq'::regclass);


--
-- TOC entry 4846 (class 2604 OID 17298)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 4847 (class 2604 OID 17305)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 4848 (class 2604 OID 17316)
-- Name: password_reset_token id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_token ALTER COLUMN id SET DEFAULT nextval('public.password_reset_token_id_seq'::regclass);


--
-- TOC entry 4849 (class 2604 OID 17323)
-- Name: product_images id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images ALTER COLUMN id SET DEFAULT nextval('public.product_images_id_seq'::regclass);


--
-- TOC entry 4857 (class 2604 OID 17511)
-- Name: product_reviews id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews ALTER COLUMN id SET DEFAULT nextval('public.product_reviews_id_seq'::regclass);


--
-- TOC entry 4850 (class 2604 OID 17330)
-- Name: product_variants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants ALTER COLUMN id SET DEFAULT nextval('public.product_variants_id_seq'::regclass);


--
-- TOC entry 4851 (class 2604 OID 17339)
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- TOC entry 4852 (class 2604 OID 17348)
-- Name: roles role_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN role_id SET DEFAULT nextval('public.roles_role_id_seq'::regclass);


--
-- TOC entry 4853 (class 2604 OID 17357)
-- Name: sports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sports ALTER COLUMN id SET DEFAULT nextval('public.sports_id_seq'::regclass);


--
-- TOC entry 4854 (class 2604 OID 17366)
-- Name: user_addresses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_addresses ALTER COLUMN id SET DEFAULT nextval('public.user_addresses_id_seq'::regclass);


--
-- TOC entry 4855 (class 2604 OID 17375)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4856 (class 2604 OID 17384)
-- Name: valid_refresh_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valid_refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.valid_refresh_tokens_id_seq'::regclass);


--
-- TOC entry 5093 (class 0 OID 17227)
-- Dependencies: 218
-- Data for Name: brands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.brands (id, banner, brand_name, created_at, description, is_active, logo, slug, updated_at) FROM stdin;
1	https://www.bing.com/th/id/OIP.Eow3_Gl9FZNS8zhNN9tcKwHaFS?w=224&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2	NIKE	2026-03-04 23:50:35.39046		t	https://th.bing.com/th/id/OIP.a1h_-mZQ1m95s5t8WUkKUwHaEK?w=280&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	NIKE	2026-03-04 23:50:35.39046
2	https://th.bing.com/th/id/OIP.--1_ExzuvXFwrbg_938NIAHaEK?w=326&h=183&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	ADIDAS	2026-03-04 23:51:44.416945		t	https://th.bing.com/th/id/OIP.--1_ExzuvXFwrbg_938NIAHaEK?w=326&h=183&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	ADIDAS	2026-03-04 23:51:44.416945
3	https://th.bing.com/th/id/OIP.gYsfjMtG6PaWUu_yiXcB1wHaHa?w=173&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	PUMA	2026-03-04 23:52:16.149081		t	https://th.bing.com/th/id/OIP.gYsfjMtG6PaWUu_yiXcB1wHaHa?w=173&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	PUMA	2026-03-04 23:52:16.149081
4	https://th.bing.com/th/id/OIP.KFTt3WO1iDckoJKawEoKPwHaEK?w=326&h=183&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	New Balance	2026-03-05 01:20:50.709861		t	https://th.bing.com/th/id/OIP.KFTt3WO1iDckoJKawEoKPwHaEK?w=326&h=183&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	New Balance	2026-03-05 01:20:50.709861
5	https://th.bing.com/th/id/OIP.xx54gLWITqP4zEJ4b028GgHaEK?w=268&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	Converse	2026-03-05 02:04:15.659596		t	https://th.bing.com/th/id/OIP.xx54gLWITqP4zEJ4b028GgHaEK?w=268&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	Converse	2026-03-05 02:04:15.659596
6	https://logowik.com/content/uploads/images/teva7613.logowik.com.webp	TEVA	2026-03-16 08:55:13.382973		t	https://logowik.com/content/uploads/images/teva7613.logowik.com.webp	TEVA	2026-03-16 08:55:13.382973
7	https://static.vecteezy.com/system/resources/previews/014/414/668/original/air-jordan-jumpman-logo-on-transparent-background-free-vector.jpg	Jordan	2026-03-16 09:01:46.589287		t	https://static.vecteezy.com/system/resources/previews/014/414/668/original/air-jordan-jumpman-logo-on-transparent-background-free-vector.jpg	Jordan	2026-03-16 09:01:46.589287
8	https://logos-world.net/wp-content/uploads/2024/09/Speedo-Logo-New.png	Speedo	2026-03-16 09:08:07.519485		t	https://logos-world.net/wp-content/uploads/2024/09/Speedo-Logo-New.png	Speedo	2026-03-16 09:08:07.519485
\.


--
-- TOC entry 5095 (class 0 OID 17237)
-- Dependencies: 220
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_items (id, quantity, cart_id, variant_id) FROM stdin;
\.


--
-- TOC entry 5097 (class 0 OID 17244)
-- Dependencies: 222
-- Data for Name: carts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carts (id, user_id) FROM stdin;
1	1
2	2
3	3
4	4
\.


--
-- TOC entry 5099 (class 0 OID 17251)
-- Dependencies: 224
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, category_name, description, parent_id) FROM stdin;
4	Nữ		\N
1	Nam		\N
5	Trẻ Em		\N
3	ÁO		1
10	QUẦN		1
9	Áo Thun		3
11	Áo Khoác		3
12	Áo Đá Bóng		3
13	Quần Ngắn		10
18	Chạy Bộ		16
17	Đá Bóng		16
19	Tennis		16
20	Áo Hoodies		3
21	Áo		4
22	Quần		4
32	Giày Thể Thao		5
31	Quần Thể Thao		5
24	Áo Thể Thao		5
15	Quần Dài Thể Thao		10
37	Áo phông		21
38	Áo polo		21
39	Áo khoác		21
40	Quần ngắn		22
41	Quần dài		22
16	GIÀY DÉP		1
23	Giày dép		4
42	Quần bó thể thao		22
44	Trail		23
43	Luyện tập		23
45	Áo thun		24
48	Quần Jogger		31
49	Quần ngắn thời trang		31
50	Giày Sneakers		32
51	Sandals		32
47	Áo bơi		24
\.


--
-- TOC entry 5101 (class 0 OID 17260)
-- Dependencies: 226
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, content, file_url, sender, sent_at, type, room_id) FROM stdin;
\.


--
-- TOC entry 5103 (class 0 OID 17269)
-- Dependencies: 228
-- Data for Name: chat_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_rooms (id, admin_name, customer_name, has_unread, last_message_at, type) FROM stdin;
1	\N	ADMIN	f	\N	\N
2	\N	ADMIN	f	\N	\N
3	\N	Shipper	f	\N	\N
4	\N	Shipper	f	\N	\N
5	\N	Nguyễn Duy Tài	f	\N	\N
6	\N	Nguyễn Duy Tài	f	\N	\N
7	\N	Nguyễn An	f	\N	\N
8	\N	Nguyễn An	f	\N	\N
\.


--
-- TOC entry 5105 (class 0 OID 17279)
-- Dependencies: 230
-- Data for Name: collection_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection_products (id, sort_order, collection_id, variant_id) FROM stdin;
\.


--
-- TOC entry 5107 (class 0 OID 17286)
-- Dependencies: 232
-- Data for Name: collections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collections (id, description, end_date, image_url, is_active, name, slug, start_date, type) FROM stdin;
\.


--
-- TOC entry 5109 (class 0 OID 17295)
-- Dependencies: 234
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, price, quantity, order_id, variant_id) FROM stdin;
1	150000.00	1	1	11
2	170000.00	1	1	15
3	7800000.00	1	2	42
4	750000.00	1	3	37
5	55000.00	1	4	16
6	130000.00	1	5	13
7	780000.00	1	6	42
8	780000.00	1	7	42
9	60000.00	2	8	22
10	85000.00	1	8	18
11	5000000.00	1	9	40
12	75000.00	1	10	30
13	170000.00	1	11	15
14	780000.00	3	12	42
15	900000.00	2	13	38
16	70000.00	2	14	31
17	373000.00	1	15	146
18	300000.00	1	15	26
19	398000.00	1	16	149
20	780000.00	1	16	42
21	300000.00	2	17	26
22	200000.00	1	18	32
\.


--
-- TOC entry 5111 (class 0 OID 17302)
-- Dependencies: 236
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, note, order_date, payment_method, phone_number, recipient_name, shipping_address, status, total_amount, user_id) FROM stdin;
1		2026-03-05 12:04:33.013434	COD	0325429584	Abc	123, 123, 123, Thành phố Hồ Chí Minh	COMPLETED	320000.00	1
4		2026-03-05 12:56:26.037528	VNPAY	0325429584	Abc	123, 123, 123, Thành phố Hồ Chí Minh	PAID	55000.00	1
3		2026-03-05 12:53:11.030264	VNPAY	0325429584	Abc	123, 123, 123, Thành phố Hồ Chí Minh	SHIPPING	750000.00	1
16		2026-03-16 09:45:02.318479	VNPAY	0911000136	Nguyễn Duy Tài	27/3A, Phường Long Thạnh Mỹ, Quận 9, Hồ Chí Minh	COMPLETED	1178000.00	3
5		2026-03-05 12:57:57.546225	VNPAY	0325429584	Abc	123, 123, 123, Thành phố Hồ Chí Minh	CANCELLED	130000.00	1
2		2026-03-05 12:25:18.473552	VNPAY	0911000136	abc	123, 123, 123, 123	COMPLETED	7800000.00	3
17		2026-03-19 12:46:57.546671	COD	0911000136	Nguyễn Duy Tài	27/3A, Phường Long Thạnh Mỹ, Quận 9, Hồ Chí Minh	COMPLETED	600000.00	3
7		2026-03-05 13:36:19.410665	VNPAY	0911000136	Nguyễn Duy Tài	27/3A, Phường Long Thạnh Mỹ, Quận 9, Hồ Chí Minh	CANCELLED	780000.00	3
8		2026-03-14 21:14:08.394954	COD	0911000136	Nguyễn Duy Tài	27/3A, Phường Long Thạnh Mỹ, Quận 9, Hồ Chí Minh	COMPLETED	205000.00	3
18		2026-03-19 13:21:26.642801	COD	0911000136	Nguyễn Duy Tài	27/3A, Phường Long Thạnh Mỹ, Quận 9, Hồ Chí Minh	COMPLETED	200000.00	3
14		2026-03-15 23:52:46.942575	COD	0911000136	Nguyễn Duy Tài	27/3A, Phường Long Thạnh Mỹ, Quận 9, Hồ Chí Minh	CANCELLED	140000.00	3
9		2026-03-15 01:00:10.747467	COD	0905133141	Nguyễn An	Số 5, ngõ 13, Long An, Cầu Vượt, Hà Nội	COMPLETED	5000000.00	4
10		2026-03-15 22:39:48.870254	COD	0905133141	Nguyễn An	Số 5, ngõ 13, Long An, Cầu Vượt, Hà Nội	PENDING	75000.00	4
11		2026-03-15 22:51:04.575327	VNPAY	0911000136	Nguyễn Duy Tài	27/3A, Phường Long Thạnh Mỹ, Quận 9, Hồ Chí Minh	CANCELLED	170000.00	3
13		2026-03-15 22:52:09.754651	COD	0911000136	Nguyễn Duy Tài	27/3A, Phường Long Thạnh Mỹ, Quận 9, Hồ Chí Minh	SHIPPING	1800000.00	3
12		2026-03-15 22:51:47.561491	COD	0911000136	Nguyễn Duy Tài	27/3A, Phường Long Thạnh Mỹ, Quận 9, Hồ Chí Minh	COMPLETED	2340000.00	3
6		2026-03-05 13:03:52.271962	COD	0325429584	Abc	123, 123, 123, Thành phố Hồ Chí Minh	CANCELLED	780000.00	1
15		2026-03-16 09:43:29.341636	VNPAY	0911000136	Nguyễn Duy Tài	27/3A, Phường Long Thạnh Mỹ, Quận 9, Hồ Chí Minh	CANCELLED	673000.00	3
\.


--
-- TOC entry 5113 (class 0 OID 17313)
-- Dependencies: 238
-- Data for Name: password_reset_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_token (id, created_date, expiry_date, token, used, user_id) FROM stdin;
1	2026-03-14 22:33:48.551438	2026-03-14 22:48:24.642397	a0ccaa20-3eb0-4466-bef9-e272eadb5841	t	4
\.


--
-- TOC entry 5115 (class 0 OID 17320)
-- Dependencies: 240
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_images (id, image_url, is_primary, variant_id) FROM stdin;
7	https://www.sporter.vn/wp-content/uploads/2023/05/Ao-bong-da-liverpool-san-nha-mua-giai-2324-chinh-thuc-1.png	t	7
8	https://tse2.mm.bing.net/th/id/OIP._F0CtCV2RwtGlNu8CnYDPAHaHa?rs=1&pid=ImgDetMain&o=7&rm=3	t	8
9	https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_500,h_500/global/632244/01/fnd/VNM/fmt/png/%C3%81o-hoodie-th%E1%BB%83-thao-%C4%91ua-xe-F1%C2%AE-nam	t	9
12	https://th.bing.com/th/id/OIP.60lT-NixWAMxjdcsfkRfBAHaHa?w=217&h=217&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	t	12
13	https://down-vn.img.susercontent.com/file/b5ca7cb421f7b8c8c7bb1039b7e47db2	t	13
14	https://down-vn.img.susercontent.com/file/b5ca7cb421f7b8c8c7bb1039b7e47db2	t	14
15	https://th.bing.com/th/id/R.e49db90e66e84d708d7d96609baa924b?rik=wpWJTH%2bR7MQloA&pid=ImgRaw&r=0	t	15
16	https://media-photos.depop.com/b1/12553009/1677413098_5b578c985c8041f48c7db1faf3610216/P0.jpg	t	16
17	https://tse3.mm.bing.net/th/id/OIP.RolWFQbSuPlff7uDLspPwgHaHa?rs=1&pid=ImgDetMain&o=7&rm=3	t	17
22	https://tse3.mm.bing.net/th/id/OIP.f7muhPx9V2dS4j1decwrJwAAAA?rs=1&pid=ImgDetMain&o=7&rm=3	t	22
23	https://pos.nvncdn.com/be3294-43017/art/20240116_60fSZ5Q4.jpeg	t	23
24	https://bizweb.dktcdn.net/100/059/568/products/z3855914030487-3a3e8233610fea3cd6105700a5d2ac41-1667613655851.jpg?v=1667613661077	t	24
25	https://pos.nvncdn.com/be3294-43017/art/20240116_60fSZ5Q4.jpeg	t	25
26	https://pos.nvncdn.com/6a2bd9-54198/ps/20240510_zBCnr7x7M7.jpeg	t	26
27	https://tse1.mm.bing.net/th/id/OIP.DA4QUIBoCphk0fFwcm8-CgHaFj?pid=ImgDet&w=187&h=140&c=7&dpr=1.3&o=7&rm=3	t	27
28	https://images-static.nykaa.com/media/catalog/product/b/4/b48bdaa37475801_n1_.jpg	t	28
29	https://dpjye2wk9gi5z.cloudfront.net/wcsstore/ExtendedSitesCatalogAssetStore/images/catalog/zoom/1027836-0109V1.jpg	t	29
30	https://product.hstatic.net/200000078815/product/iq2654_01_be805657dea14bc6b5425b91bb261385_master.jpg	t	30
31	https://product.hstatic.net/200000078815/product/iq2654_01_be805657dea14bc6b5425b91bb261385_master.jpg	t	31
32	https://cdn.hstatic.net/products/200000078815/68816702_03_7252721661cd45c6883b43408cbbf49e_master.jpg	t	32
33	https://cdn.hstatic.net/products/200000078815/68816702_03_7252721661cd45c6883b43408cbbf49e_master.jpg	t	33
34	https://cdn.hstatic.net/products/200000078815/68237802_01_7416a6e9c9bf454e896f3c6f2298d383_master.jpg	t	34
35	https://cdn.hstatic.net/products/200000078815/68237802_01_7416a6e9c9bf454e896f3c6f2298d383_master.jpg	t	35
36	https://cdn.hstatic.net/products/200000078815/62924511_01_800fa0be912b4a0b88fb283c61ecc56e_master.jpg	t	36
37	https://cdn.hstatic.net/products/200000078815/62978651_e951362fcfa2425ca8d285c5f2e275ae_master.jpg	t	37
38	https://cdn.hstatic.net/products/200000078815/62978651_e951362fcfa2425ca8d285c5f2e275ae_master.jpg	t	38
39	https://cdn.hstatic.net/products/200000078815/52658401_02_0ae834391e2145e99f1ba703eda1e250_master.jpg	t	39
40	https://cdn.hstatic.net/products/200000078815/52658401_02_0ae834391e2145e99f1ba703eda1e250_master.jpg	t	40
41	https://cdn.hstatic.net/products/200000078815/jl8710-05_3a52fad9d5da4d1096e65479af285347_master.jpg	t	41
42	https://cdn.hstatic.net/products/200000078815/jl8710-05_3a52fad9d5da4d1096e65479af285347_master.jpg	t	42
111	https://th.bing.com/th/id/OIP.fWbhiCuvahSE2or3okMPQAHaHa?w=190&h=190&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	t	111
112	https://th.bing.com/th/id/OIP.fWbhiCuvahSE2or3okMPQAHaHa?w=190&h=190&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3	t	112
137	https://bizweb.dktcdn.net/100/419/932/products/41-f356bdf6a2cc44ee977bc8992c4b8a08-master-jpeg.jpg?v=1637669102450	t	123
138	https://bizweb.dktcdn.net/100/419/932/products/41-f356bdf6a2cc44ee977bc8992c4b8a08-master-jpeg.jpg?v=1637669102450	t	11
139	https://supersports.com.vn/cdn/shop/files/FB5019-010-1.jpg?v=1694596126&width=1000	t	125
140	https://supersports.com.vn/cdn/shop/files/FB5019-010-1.jpg?v=1694596126&width=1000	t	126
141	https://supersports.com.vn/cdn/shop/files/IN9474-1.jpg?v=1709626944&width=1000	t	127
142	https://supersports.com.vn/cdn/shop/files/IN9474-1.jpg?v=1709626944&width=1000	t	128
143	https://supersports.com.vn/cdn/shop/products/GR3866-2.jpg?v=1766030082&width=1600	t	129
144	https://supersports.com.vn/cdn/shop/files/FB7030-464-1.jpg?v=1728985664&width=1000	t	130
145	https://supersports.com.vn/cdn/shop/files/FB7030-464-1.jpg?v=1728985664&width=1000	t	131
146	https://supersports.com.vn/cdn/shop/files/64.98061-1.jpg?v=1700742745&width=1000	t	132
147	https://supersports.com.vn/cdn/shop/files/64.98061-1.jpg?v=1700742745&width=1000	t	133
148	https://supersports.com.vn/cdn/shop/files/ID8636-1.jpg?v=1727859648&width=1000	t	134
149	https://supersports.com.vn/cdn/shop/files/ID8636-1.jpg?v=1727859648&width=1000	t	135
150	https://5sfashion.vn/storage/upload/images/ckeditor/M59J1pEhnin5vGvr8auUJ0C2cqToXtO4uBYTGYx1.jpg	t	18
151	https://supersports.com.vn/cdn/shop/files/36517001-1.jpg?v=1700742738&width=1000	t	136
152	https://supersports.com.vn/cdn/shop/files/36517001-1.jpg?v=1700742738&width=1000	t	137
153	https://supersports.com.vn/cdn/shop/files/IG2511-1.jpg?v=1696501626&width=1000	t	138
154	https://supersports.com.vn/cdn/shop/files/IG2511-1.jpg?v=1696501626&width=1000	t	139
155	https://supersports.com.vn/cdn/shop/files/1019390C-BPLC-1.jpg?v=1708328647&width=1000	t	140
156	https://supersports.com.vn/cdn/shop/files/1019390C-SBLK-1.jpg?v=1695281238&width=1000	t	141
157	https://supersports.com.vn/cdn/shop/files/95D533-782-1.jpg?v=1731057652&width=1000	t	142
158	https://supersports.com.vn/cdn/shop/files/95D533-023-1.jpg?v=1731057629&width=1000	t	143
159	https://supersports.com.vn/cdn/shop/files/IW0668-1.jpg?v=1722920156&width=1000	t	144
160	https://supersports.com.vn/cdn/shop/files/IW0668-1.jpg?v=1722920156&width=1000	t	145
161	https://supersports.com.vn/cdn/shop/files/8-00323715493-1.jpg?v=1695283914&width=1000	t	146
162	https://supersports.com.vn/cdn/shop/files/8-00323715493-1.jpg?v=1695283914&width=1000	t	147
163	https://supersports.com.vn/cdn/shop/files/8-00319215432-1.jpg?v=1734506768&width=1000	t	148
164	https://supersports.com.vn/cdn/shop/files/8-00319215432-1.jpg?v=1734506768&width=1000	t	149
165	https://supersports.com.vn/cdn/shop/files/95D313-023-1.jpg?v=1731057562&width=1000	t	150
166	https://supersports.com.vn/cdn/shop/files/95D313-023-1.jpg?v=1731057562&width=1000	t	151
167	https://supersports.com.vn/cdn/shop/files/95D065-782-1.jpg?v=1708327207&width=1000	t	152
168	https://supersports.com.vn/cdn/shop/files/95D065-782-1.jpg?v=1708327207&width=1000	t	153
\.


--
-- TOC entry 5131 (class 0 OID 17508)
-- Dependencies: 256
-- Data for Name: product_reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_reviews (id, comment, created_at, rating, order_item_id, product_id, user_id) FROM stdin;
\.


--
-- TOC entry 5117 (class 0 OID 17327)
-- Dependencies: 242
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variants (id, color, price, size, sku, stock_quantity, product_id, version) FROM stdin;
7	Đỏ	50000.00	M	AOL-O-M	10	2	\N
8	Đen	120000.00	XL	AOH-EN-XL	5	3	\N
9	Trắng	150000.00	XL	AOH-TRA-XL	3	4	\N
12	Đen 	90000.00	M	AOK-EN-M	12	6	\N
14	Trắng	130000.00	XL	AOT-TRA-XL	15	7	\N
17	Đen	58000.00	XL	QUA-EN-XL	10	10	\N
23	Xanh Lá	200000.00	L	GIA-XAN-L	1	13	\N
24	CAM	200000.00	43	GIA-CAM-43	4	14	\N
25	Xanh Lá	200000.00	42	GIA-XAN-L	1	13	\N
27	Cam	290000.00	41	GIA-CAM-41	0	15	\N
28	Đen	350000.00	41	GIA-EN-41	3	16	\N
29	Trắng	400000.00	43	GIA-TRA-43	7	16	\N
33	Trắng	250000.00	XL	AOP-TRA-XL	7	18	\N
34	Trắng	270000.00	M	AOP-TRA-M	13	19	\N
35	Trắng	300000.00	L	AOP-TRA-L	10	19	\N
36	Xanh	450000.00	M	AOP-XAN-M	16	20	\N
39	Đen	400000.00	L	AOK-EN-L	11	22	\N
41	Tím	800000.00	L	QUA-TIM-L	9	23	\N
111	Đỏ	50000.00	L	AOM-O-L	50	1	\N
112	Đỏ	70000.00	XL	AOM-O-XL	20	1	\N
37	Đen	750000.00	M	AOK-EN-M	21	21	\N
16	Xám	55000.00	L	QUA-XAM-L	2	9	\N
11	Xanh, Đen	150000.00	XL	AOK-XAN-XL	4	5	\N
151	Đen	759000.00	M	QUA-EN-M	17	39	\N
13	Đen	130000.00	XL	AOT-EN-XL	12	7	\N
152	Trắng	759000.00	S	QUA-TRA-S	7	40	\N
153	Trắng	759000.00	M	QUA-TRA-M	8	40	\N
22	Đen	60000.00	M	QUA-EN-M	3	12	\N
18	Đen	85000.00	XL	QUA-EN-XL	3	11	\N
40	Đen	5000000.00	M	AOK-EN-M	3	22	\N
30	Đen	75000.00	XL	AOP-EN-XL	3	17	\N
15	Đen	170000.00	XL	AOT-EN-XL	4	8	\N
38	Đen	900000.00	L	AOK-EN-L	11	21	\N
31	Đen	70000.00	L	AOP-EN-L	4	17	\N
123	Xanh, Đen	200000.00	L	AOK-XAN-L	4	5	\N
125	Đen	700000.00	S	QUA-EN-S	8	26	\N
126	Đen	750000.00	L	QUA-EN-L	10	26	\N
127	Đen	1181000.00	XS	QUA-EN-XS	13	27	\N
128	Đen	1141000.00	S	QUA-EN-S	7	27	\N
129	Đen	444000.00	XS	QUA-EN-XS	15	28	\N
130	Xanh dương	1041000.00	XL	QUA-XAN-XL	7	29	\N
131	Xanh dương	1041000.00	L	QUA-XAN-L	5	29	\N
132	Xám	2200000.00	33	GIA-XAM-33	9	30	\N
133	Xám	2200000.00	32	GIA-XAM-32	7	30	\N
134	Xanh dương	2219000.00	32	GIA-XAN-32	7	31	\N
135	Xanh dương	2219000.00	33	GIA-XAN-33	8	31	\N
136	Đen	796000.00	23	GIA-EN-23	15	32	\N
137	Đen	796000.00	22	GIA-EN-22	7	32	\N
138	Trắng	5100000.00	20	GIA-TRA-20	7	33	\N
139	Trắng	5100000.00	21	GIA-TRA-21	6	33	\N
140	Hồng	200000.00	17	GIA-HON-17	22	34	\N
141	Đen	200000.00	17	GIA-EN-17	14	34	\N
142	Trắng	399000.00	M	AOT-TRA-M	13	35	\N
143	Đen	399000.00	M	AOT-EN-M	22	35	\N
144	Xanh 	444000.00	104	AOT-XAN-104	17	36	\N
145	Xanh 	450000.00	122	AOT-XAN-122	5	36	\N
147	Cam	373000.00	L	AOB-CAM-L	7	37	\N
148	Hồng	398000.00	L	AOB-HON-L	9	38	\N
150	Đen	759000.00	S	QUA-EN-S	13	39	\N
146	Cam	373000.00	M	AOB-CAM-M	6	37	\N
149	Hồng	398000.00	M	AOB-HON-M	6	38	\N
42	Tím	780000.00	M	QUA-TIM-M	8	23	\N
26	Hồng	300000.00	42	GIA-HON-42	2	15	\N
32	Trắng	200000.00	L	AOP-TRA-L	4	18	\N
\.


--
-- TOC entry 5119 (class 0 OID 17336)
-- Dependencies: 244
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, description, product_name, brand_id, category_id, sport_id, average_rating, is_active) FROM stdin;
1		Áo MU	2	12	2	\N	\N
2		Áo Liverpool	1	12	2	\N	\N
3		Áo Hoodies PUMA	3	20	6	\N	\N
4		Áo Hoodies thể thao đua xe F1	3	20	7	\N	\N
5		Áo khoác New Balance	4	11	6	\N	\N
6		Áo Khoác PUMA	3	11	6	\N	\N
7		Áo thun ADIDAS	2	9	3	\N	\N
8		Áo thun PUMA	3	9	6	\N	\N
9		Quần Short PUMA	3	13	3	\N	\N
10		Quần short ADIDAS	2	13	3	\N	\N
11		Quần dài thể thao Converse	5	15	6	\N	\N
12		Quần dài thể thao PUMA	3	15	6	\N	\N
13		Giày chạy bộ ADIDAS	2	18	6	\N	\N
14		Giày chạy bộ NIKE	1	18	6	\N	\N
15	Giày Đá Bóng Nike Air Zoom Mercurial Superfly 9 Elite Hồng Cao Cổ TF	Giày Đá Bóng Nike 	1	17	2	\N	\N
16	Tenis Puma RS-X Gen Hombre	Giày tennis 	3	19	3	\N	\N
17	Áo Phông Tập Luyện Nữ ADIDAS Wtr D4T T IQ2654 mang lại sự thoải mái tối đa và hiệu suất tuyệt vời trong suốt quá trình luyện tập. Với chất liệu tái chế và thiết kế hiện đại, chiếc áo này sẽ giúp bạn di chuyển tự do trong mọi buổi tập HIIT, tập tạ hay yoga. Công nghệ AEROREADY giúp thấm hút mồ hôi hiệu quả, giữ cho cơ thể bạn luôn khô ráo và thoải mái.	Áo phông ADIDAS	2	37	3	\N	\N
18	Áo Phông - Áo thun Thể Thao Nữ PUMA Graphic Stacked Tee 68816702	Áo Phông - Áo thun Thể Thao Nữ PUMA	3	37	3	\N	\N
19	Áo Polo Thể Thao Nữ PUMA Ess Polo 68237802	Áo Polo Thể Thao Nữ PUMA	3	38	3	\N	\N
20	Áo Polo Golf Nữ PUMA W Cloudspun Bridges Ss Polo 62924511	Áo Polo Golf Nữ PUMA	3	38	9	\N	\N
21	Áo Khoác Thể Thao Unisex PUMA Future Archive Relaxed Track Jacket 62978651	Áo Khoác Thể Thao Unisex PUMA	3	39	6	\N	\N
22	\nÁo Khoác Chạy Nữ PUMA Run Velocity Woven Jacket W 52658401	Áo Khoác Chạy Nữ PUMA	3	39	6	\N	\N
23	Quần Đùi Chạy Nữ ADIDAS Otr Aop Short W JL8710	Quần Đùi Chạy Nữ ADIDAS	2	40	6	\N	\N
26	Quần Dài Thể Thao Nữ Nike Dri-Fit One Ultra High-Waisted - Đen	Quần Dài Thể Thao Nữ Nike	1	41	6	\N	\N
27	Quần Dài Thể Thao Nữ Adidas Future Icons 3-Stripes Open Hem - Đen	Quần Dài Thể Thao Nữ Adidas Future	1	41	6	\N	\N
28	Quần Bó Thể Thao Ngắn Nữ Adidas Esssentials Bike - Đen\n	Quần Bó Thể Thao Ngắn Nữ Adidas	2	42	5	\N	\N
29	Quần Bó Thể Thao Nữ Nike Dri-Fit Fast Mid-Rise 7/8 - Xanh Dương	Quần Bó Thể Thao Nữ Nike	1	42	6	\N	\N
30	Giày Chạy Bộ Nữ On Cloudvista - Xám	Giày Chạy Bộ Nữ	1	44	6	\N	\N
31	Giày Luyện Tập Nữ Adidas Dropset 3 Trainer - Xanh Dương	Giày Luyện Tập Nữ Adidas	2	43	6	\N	\N
32	Giày Thời Trang Trẻ Em Puma Smash V2 - Đen	Giày Thời Trang Trẻ Em Puma	3	50	6	\N	\N
33	Giày Thể Thao Trẻ Em Adidas Advantage - Trắng	Giày Thể Thao Trẻ Em Adidas	2	50	6	\N	\N
34	Giày Sandal Trẻ Em Teva Hurricane - Nhiều màu	Giày Sandal Trẻ Em Teva Hurricane	6	51	6	\N	\N
35	Áo Thun Bé Trai Jordan See Me Shine Short Sleeve	Áo Thun Bé Trai Jordan	7	45	2	\N	\N
36	Áo Thun Trẻ Em Adidas Adidas X Disney Mickey Mouse	Áo Thun Bé Trai Jordan See Me Shine Short Sleeve	2	45	4	\N	\N
37	Áo Bơi Chống Nắng Bé Trai Speedo Unisex Essentials	Áo Bơi Chống Nắng Bé Trai Speedo	8	47	5	\N	\N
38	Áo Bơi Chống Nắng Bé Gái Speedo Essential Hood	Áo Bơi Chống Nắng Bé Gái Speedo	8	47	5	\N	\N
39	Quần Ngắn Bé Trai Jordan Sport Diamond	Quần Ngắn Bé Trai	7	49	6	\N	\N
40	Quần Ngắn Bé Trai Jordan Mj Essentials Ft Aop	Quần Ngắn Bé Trai Jordan	7	49	6	\N	\N
\.


--
-- TOC entry 5121 (class 0 OID 17345)
-- Dependencies: 246
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (role_id, role_code, role_description, role_name) FROM stdin;
1	ADMIN	Toàn quyền quản lý hệ thống	Quản Trị Viên
2	SHIPPER	Giao hàng và thay đổi trạng thái đơn hàng	Người giao hàng
3	MEMBER	Người dùng thông thường	Thành Viên
\.


--
-- TOC entry 5123 (class 0 OID 17354)
-- Dependencies: 248
-- Data for Name: sports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sports (id, description, sport_name) FROM stdin;
2		BÓNG ĐÁ
3		QUẦN VỢT
4		CẦU LÔNG
5		BƠI LỘI
6		CHẠY BỘ
7		ĐUA XE
9		Golf
\.


--
-- TOC entry 5125 (class 0 OID 17363)
-- Dependencies: 250
-- Data for Name: user_addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_addresses (id, city, district, is_default, phone_number, recipient_name, street, ward, user_id) FROM stdin;
1	Thành phố Hồ Chí Minh	123	t	0325429584	Abc	123	123	1
2	Hồ Chí Minh	Quận 9	t	0911000136	Nguyễn Duy Tài	27/3A	Phường Long Thạnh Mỹ	3
3	Hà Nội	Cầu Vượt	t	0905133141	Nguyễn An	Số 5, ngõ 13	Long An	4
\.


--
-- TOC entry 5127 (class 0 OID 17372)
-- Dependencies: 252
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, email, failed_login_attempts, full_name, last_login_date, last_password_change_date, lock_time, password, phone_number, status, role_id) FROM stdin;
1	2026-03-04 23:46:38.363525	admin@gmail.com	0	ADMIN	2026-06-18 10:18:21.012967	2026-06-18 10:18:21.012967	\N	$2a$12$Sfd56.qndFO5xUsdg7N26usyRcQd/.nOMcAcgPgt/sxF9DD3OSRdq	0334525435	t	1
2	2026-03-05 12:00:43.73266	shipper@gmail.com	0	Shipper	2026-06-18 10:18:21.012967	2026-06-18 10:18:21.012967	\N	$2a$12$Sfd56.qndFO5xUsdg7N26usyRcQd/.nOMcAcgPgt/sxF9DD3OSRdq	0328167241	t	2
3	2026-03-05 12:01:00.447142	nguyenphuocloiphuyen1@gmail.com	0	Nguyễn Duy Tài	2026-06-18 10:18:21.012967	2026-06-18 10:18:21.012967	\N	$2a$12$Sfd56.qndFO5xUsdg7N26usyRcQd/.nOMcAcgPgt/sxF9DD3OSRdq	0325429584	t	3
4	2026-03-14 22:13:15.949156	npsanhzt@gmail.com	0	Nguyễn An	2026-06-18 10:18:21.012967	2026-06-18 10:18:21.012967	\N	$2a$12$Sfd56.qndFO5xUsdg7N26usyRcQd/.nOMcAcgPgt/sxF9DD3OSRdq	0357489487	t	3
\.


--
-- TOC entry 5129 (class 0 OID 17381)
-- Dependencies: 254
-- Data for Name: valid_refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.valid_refresh_tokens (id, created_at, expired_time, jwt_id, revoked, user_id) FROM stdin;
\.


--
-- TOC entry 5157 (class 0 OID 0)
-- Dependencies: 217
-- Name: brands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.brands_id_seq', 8, true);


--
-- TOC entry 5158 (class 0 OID 0)
-- Dependencies: 219
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 27, true);


--
-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 221
-- Name: carts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.carts_id_seq', 4, true);


--
-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 223
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_seq', 51, true);


--
-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 225
-- Name: chat_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_messages_id_seq', 1, false);


--
-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 227
-- Name: chat_rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_rooms_id_seq', 8, true);


--
-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 229
-- Name: collection_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collection_products_id_seq', 1, false);


--
-- TOC entry 5164 (class 0 OID 0)
-- Dependencies: 231
-- Name: collections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collections_id_seq', 1, false);


--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 233
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 22, true);


--
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 235
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 18, true);


--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 237
-- Name: password_reset_token_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.password_reset_token_id_seq', 1, true);


--
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 239
-- Name: product_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_images_id_seq', 168, true);


--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 255
-- Name: product_reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_reviews_id_seq', 1, false);


--
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 241
-- Name: product_variants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_variants_id_seq', 153, true);


--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 243
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 40, true);


--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 245
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_role_id_seq', 3, true);


--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 247
-- Name: sports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sports_id_seq', 9, true);


--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 249
-- Name: user_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_addresses_id_seq', 3, true);


--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 251
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 253
-- Name: valid_refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.valid_refresh_tokens_id_seq', 1, false);


--
-- TOC entry 4862 (class 2606 OID 17235)
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- TOC entry 4866 (class 2606 OID 17242)
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4868 (class 2606 OID 17249)
-- Name: carts carts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (id);


--
-- TOC entry 4872 (class 2606 OID 17258)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4876 (class 2606 OID 17267)
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 4878 (class 2606 OID 17277)
-- Name: chat_rooms chat_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_rooms
    ADD CONSTRAINT chat_rooms_pkey PRIMARY KEY (id);


--
-- TOC entry 4880 (class 2606 OID 17284)
-- Name: collection_products collection_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_products
    ADD CONSTRAINT collection_products_pkey PRIMARY KEY (id);


--
-- TOC entry 4882 (class 2606 OID 17293)
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- TOC entry 4884 (class 2606 OID 17300)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4886 (class 2606 OID 17311)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 4888 (class 2606 OID 17318)
-- Name: password_reset_token password_reset_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_token
    ADD CONSTRAINT password_reset_token_pkey PRIMARY KEY (id);


--
-- TOC entry 4894 (class 2606 OID 17325)
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);


--
-- TOC entry 4922 (class 2606 OID 17515)
-- Name: product_reviews product_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_pkey PRIMARY KEY (id);


--
-- TOC entry 4896 (class 2606 OID 17334)
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_pkey PRIMARY KEY (id);


--
-- TOC entry 4898 (class 2606 OID 17343)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 4900 (class 2606 OID 17352)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- TOC entry 4906 (class 2606 OID 17361)
-- Name: sports sports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sports
    ADD CONSTRAINT sports_pkey PRIMARY KEY (id);


--
-- TOC entry 4874 (class 2606 OID 17392)
-- Name: categories uk_41g4n0emuvcm3qyf1f6cn43c0; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT uk_41g4n0emuvcm3qyf1f6cn43c0 UNIQUE (category_name);


--
-- TOC entry 4870 (class 2606 OID 17390)
-- Name: carts uk_64t7ox312pqal3p7fg9o503c2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT uk_64t7ox312pqal3p7fg9o503c2 UNIQUE (user_id);


--
-- TOC entry 4912 (class 2606 OID 17404)
-- Name: users uk_6dotkott2kjsp8vw4d0m25fb7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uk_6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email);


--
-- TOC entry 4902 (class 2606 OID 17400)
-- Name: roles uk_716hgxp60ym1lifrdgp67xt5k; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT uk_716hgxp60ym1lifrdgp67xt5k UNIQUE (role_name);


--
-- TOC entry 4904 (class 2606 OID 17398)
-- Name: roles uk_949pwsnk7kxk0px0tbj3r3web; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT uk_949pwsnk7kxk0px0tbj3r3web UNIQUE (role_code);


--
-- TOC entry 4914 (class 2606 OID 17406)
-- Name: users uk_9q63snka3mdh91as4io72espi; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uk_9q63snka3mdh91as4io72espi UNIQUE (phone_number);


--
-- TOC entry 4918 (class 2606 OID 17408)
-- Name: valid_refresh_tokens uk_a3piwhssyn5ixnhr83j9tndy2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valid_refresh_tokens
    ADD CONSTRAINT uk_a3piwhssyn5ixnhr83j9tndy2 UNIQUE (jwt_id);


--
-- TOC entry 4908 (class 2606 OID 17402)
-- Name: sports uk_cs1vpkeju799gcxbq5gc0lac1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sports
    ADD CONSTRAINT uk_cs1vpkeju799gcxbq5gc0lac1 UNIQUE (sport_name);


--
-- TOC entry 4890 (class 2606 OID 17396)
-- Name: password_reset_token uk_f90ivichjaokvmovxpnlm5nin; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_token
    ADD CONSTRAINT uk_f90ivichjaokvmovxpnlm5nin UNIQUE (user_id);


--
-- TOC entry 4892 (class 2606 OID 17394)
-- Name: password_reset_token uk_g0guo4k8krgpwuagos61oc06j; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_token
    ADD CONSTRAINT uk_g0guo4k8krgpwuagos61oc06j UNIQUE (token);


--
-- TOC entry 4924 (class 2606 OID 17517)
-- Name: product_reviews uk_i19palx1qyrw7n6jqn26mn3xb; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT uk_i19palx1qyrw7n6jqn26mn3xb UNIQUE (order_item_id);


--
-- TOC entry 4864 (class 2606 OID 17388)
-- Name: brands uk_pnhnc9urm6fro7oseu9vka70q; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT uk_pnhnc9urm6fro7oseu9vka70q UNIQUE (slug);


--
-- TOC entry 4910 (class 2606 OID 17370)
-- Name: user_addresses user_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_addresses
    ADD CONSTRAINT user_addresses_pkey PRIMARY KEY (id);


--
-- TOC entry 4916 (class 2606 OID 17379)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4920 (class 2606 OID 17386)
-- Name: valid_refresh_tokens valid_refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valid_refresh_tokens
    ADD CONSTRAINT valid_refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4934 (class 2606 OID 17454)
-- Name: orders fk32ql8ubntj5uh44ph9659tiih; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk32ql8ubntj5uh44ph9659tiih FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4944 (class 2606 OID 17523)
-- Name: product_reviews fk35kxxqe2g9r4mww80w9e3tnw9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT fk35kxxqe2g9r4mww80w9e3tnw9 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 4945 (class 2606 OID 17528)
-- Name: product_reviews fk58i39bhws2hss3tbcvdmrm60f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT fk58i39bhws2hss3tbcvdmrm60f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4925 (class 2606 OID 17414)
-- Name: cart_items fk5yyw1o0dor9gmxfra1dqvn4qa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT fk5yyw1o0dor9gmxfra1dqvn4qa FOREIGN KEY (variant_id) REFERENCES public.product_variants(id);


--
-- TOC entry 4935 (class 2606 OID 17459)
-- Name: password_reset_token fk83nsrttkwkb6ym0anu051mtxn; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_token
    ADD CONSTRAINT fk83nsrttkwkb6ym0anu051mtxn FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4938 (class 2606 OID 17474)
-- Name: products fka3a4mpsfdf4d2y6r8ra3sc8mv; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fka3a4mpsfdf4d2y6r8ra3sc8mv FOREIGN KEY (brand_id) REFERENCES public.brands(id);


--
-- TOC entry 4946 (class 2606 OID 17518)
-- Name: product_reviews fkau5g3dylb9eh7ua5xjjw6uopw; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT fkau5g3dylb9eh7ua5xjjw6uopw FOREIGN KEY (order_item_id) REFERENCES public.order_items(id);


--
-- TOC entry 4930 (class 2606 OID 17434)
-- Name: collection_products fkaxoi4xo8kxr6ybr4agejey9p5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_products
    ADD CONSTRAINT fkaxoi4xo8kxr6ybr4agejey9p5 FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- TOC entry 4927 (class 2606 OID 17419)
-- Name: carts fkb5o626f86h46m4s7ms6ginnop; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT fkb5o626f86h46m4s7ms6ginnop FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4932 (class 2606 OID 17444)
-- Name: order_items fkbioxgbv59vetrxe0ejfubep1w; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fkbioxgbv59vetrxe0ejfubep1w FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- TOC entry 4939 (class 2606 OID 17484)
-- Name: products fkcxxrw6itsu6s6l4i463rnwh6v; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fkcxxrw6itsu6s6l4i463rnwh6v FOREIGN KEY (sport_id) REFERENCES public.sports(id);


--
-- TOC entry 4933 (class 2606 OID 17449)
-- Name: order_items fkemq71edpbn9wsxnxncfn1algp; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fkemq71edpbn9wsxnxncfn1algp FOREIGN KEY (variant_id) REFERENCES public.product_variants(id);


--
-- TOC entry 4929 (class 2606 OID 17429)
-- Name: chat_messages fkhalwepod3944695ji0suwoqb9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT fkhalwepod3944695ji0suwoqb9 FOREIGN KEY (room_id) REFERENCES public.chat_rooms(id);


--
-- TOC entry 4943 (class 2606 OID 17499)
-- Name: valid_refresh_tokens fkkp9ek9g1oiey5ysyxtvhvwpg7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valid_refresh_tokens
    ADD CONSTRAINT fkkp9ek9g1oiey5ysyxtvhvwpg7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4941 (class 2606 OID 17489)
-- Name: user_addresses fkn2fisxyyu3l9wlch3ve2nocgp; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_addresses
    ADD CONSTRAINT fkn2fisxyyu3l9wlch3ve2nocgp FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4931 (class 2606 OID 17439)
-- Name: collection_products fknqyubvcgf8srsg8mm77sbrtvs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_products
    ADD CONSTRAINT fknqyubvcgf8srsg8mm77sbrtvs FOREIGN KEY (variant_id) REFERENCES public.product_variants(id);


--
-- TOC entry 4940 (class 2606 OID 17479)
-- Name: products fkog2rp4qthbtt2lfyhfo32lsw9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fkog2rp4qthbtt2lfyhfo32lsw9 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- TOC entry 4937 (class 2606 OID 17469)
-- Name: product_variants fkosqitn4s405cynmhb87lkvuau; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT fkosqitn4s405cynmhb87lkvuau FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 4942 (class 2606 OID 17494)
-- Name: users fkp56c1712k691lhsyewcssf40f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fkp56c1712k691lhsyewcssf40f FOREIGN KEY (role_id) REFERENCES public.roles(role_id);


--
-- TOC entry 4926 (class 2606 OID 17409)
-- Name: cart_items fkpcttvuq4mxppo8sxggjtn5i2c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT fkpcttvuq4mxppo8sxggjtn5i2c FOREIGN KEY (cart_id) REFERENCES public.carts(id);


--
-- TOC entry 4936 (class 2606 OID 17464)
-- Name: product_images fkqnqjv00ocaxfmu2k6b99ycdad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT fkqnqjv00ocaxfmu2k6b99ycdad FOREIGN KEY (variant_id) REFERENCES public.product_variants(id);


--
-- TOC entry 4928 (class 2606 OID 17424)
-- Name: categories fksaok720gsu4u2wrgbk10b5n8d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fksaok720gsu4u2wrgbk10b5n8d FOREIGN KEY (parent_id) REFERENCES public.categories(id);


-- Completed on 2026-06-16 16:15:19

--
-- PostgreSQL database dump complete
--

\unrestrict NbdgMZE92MgSutAGTBCIalsG4Dmek8GLzejCAKeerLGeb0xbCik9Wdg7zl2xoR1
